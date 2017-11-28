# frozen_string_literal: true

RSpec.describe ImportingDocumentsReanalyzer do
  let(:repository) { create(:repository_compound) }
  let(:file_version) do
    create(:file_version,
           evaluation_state: 'finished_successfully',
           repository: repository)
  end

  subject { ImportingDocumentsReanalyzer.new(file_version.id) }

  context 'return value when there are older FileVersions' do
    before do
      allow_any_instance_of(Bringit::Wrapper).
        to receive(:log).
        with(include(ref: file_version.commit_sha, only_commit_sha: true)).
        and_return([older_file_version.commit_sha,
                    file_version.commit_sha])

      allow(subject).to receive(:process)
    end

    %w(not_yet_enqueued enqueued processing).each do |state|
      context "with evaluation_state #{state}" do
        let(:older_file_version) do
          create(:file_version, evaluation_state: state, repository: repository)
        end

        it 'returns :requeue' do
          expect(subject.call).to eq(:requeue)
        end
      end
    end

    %w(finished_successfully finished_unsuccessfully).each do |state|
      context "with evaluation_state #{state}" do
        let(:older_file_version) do
          create(:file_version, evaluation_state: state, repository: repository)
        end

        it 'returns :done' do
          expect(subject.call).to eq(:done)
        end
      end
    end
  end

  context 'detecting an import' do
    before do
      # This is called by MultiBlob#save, which is called by the
      # :additional_commit factory. It needs to be perfomed inline.
      allow(ProcessCommitJob).to receive(:perform_later) do |*args|
        ProcessCommitJob.new.perform(*args)
      end
      # However, nothing should be published to RabbitMQ. So, stub it:
      stub = double(:invoker)
      allow(HetsAgent::Invoker).to receive(:new).and_return(stub)
      allow(stub).to receive(:call)
    end

    let(:repository) { create(:repository_compound) }
    let(:git) { repository.git }
    let(:file_version_creator) do
      lambda do |path = nil|
        options = {repository: repository,
                   files: [{path: path ? path : generate(:filepath),
                            content: generate(:content),
                            encoding: 'plain',
                            action: path ? 'update' : 'create'}]}
        commit_sha = create(:additional_commit, options)

        file_version = FileVersion.first(commit_sha: commit_sha)
        file_version.evaluation_state = 'finished_successfully'
        file_version.save
        file_version
      end
    end

    let!(:imported_file_version) { file_version_creator.call }
    let!(:imported_document) do
      create(:document, file_version: imported_file_version)
    end

    let!(:old_file_version) { file_version_creator.call }
    let!(:old_document) { create(:document, file_version: old_file_version) }

    let!(:importing_file_version1) { file_version_creator.call }
    let!(:importing_document1) do
      create(:document, file_version: importing_file_version1)
    end

    let!(:importing_file_version2) { file_version_creator.call }
    let!(:importing_document2) do
      create(:document, file_version: importing_file_version2)
    end

    let!(:unrelated_document) do
      create(:document, file_version: file_version_creator.call)
    end

    let!(:updated_file_version) do
      file_version_creator.call(old_file_version.path)
    end
    let!(:updated_document) do
      create(:document, file_version: updated_file_version)
    end

    let!(:updated_unrelated_file_version) do
      file_version_creator.call(unrelated_document.file_version.path)
    end
    let!(:updated_unrelated_document) do
      create(:document, file_version: updated_unrelated_file_version)
    end

    let(:hets_agent_invoker) { double(:invoker) }

    before do
      create(:document_link, source: old_document, target: imported_document)
      create(:document_link, source: importing_document1, target: old_document)
      create(:document_link, source: importing_document2, target: old_document)

      allow(HetsAgent::ReanalysisRequestCollection).
        to receive(:new).and_call_original

      allow(HetsAgent::Invoker).to receive(:new).and_return(hets_agent_invoker)
      allow(hets_agent_invoker).to receive(:call)

      subject.call
    end

    context 'when there is no import' do
      let(:file_version) { updated_unrelated_document.file_version }

      it 'does not enqueue jobs' do
        expect(hets_agent_invoker).not_to have_received(:call)
      end
    end

    context 'when there is no previous version' do
      let(:file_version) { old_file_version }

      it 'does not enqueue jobs' do
        expect(hets_agent_invoker).not_to have_received(:call)
      end
    end

    context 'when there is a previous version' do
      let(:file_version) { updated_file_version }

      it 'creates new FileVersions for each importing document file' do
        [importing_file_version1,
         importing_file_version2].each do |importing_file_version|
          found = FileVersion.first(repository_id: repository.id,
                                    commit_sha: file_version.commit_sha,
                                    path: importing_file_version.path)
          expect(found).not_to be(nil)
        end
      end

      it 'removes the FileVersionParents of each importing document file' do
        [updated_file_version,
         updated_unrelated_file_version].map(&:commit_sha).each do |commit_sha|
          [importing_file_version1,
           importing_file_version2].each do |importing_file_version|
            found = FileVersionParent.
              first(last_changed_file_version_id: importing_file_version.id,
                    queried_sha: commit_sha)
            expect(found).to be(nil)
          end
        end
      end

      it 'creates FileVersionParents of each importing document file' do
        [updated_file_version,
         updated_unrelated_file_version].map(&:commit_sha).each do |commit_sha|
          [importing_file_version1,
           importing_file_version2].each do |importing_file_version|
            new_file_version = FileVersion.
              first(repository_id: repository.id,
                    commit_sha: file_version.commit_sha,
                    path: importing_file_version.path)
            found = FileVersionParent.
              first(last_changed_file_version_id: new_file_version.id,
                    queried_sha: commit_sha)
            expect(found).not_to be(nil)
          end
        end
      end

      it 'creates a request for re-analysis for every importing document' do
        [importing_file_version1,
         importing_file_version2].each do |importing_file_version|
          expect(HetsAgent::ReanalysisRequestCollection).
            to have_received(:new).
            with(eq(FileVersion.first(repository_id: repository.id,
                                      commit_sha: file_version.commit_sha,
                                      path: importing_file_version.path)))
        end
      end

      it 'enqueues jobs for each importing document' do
        expect(hets_agent_invoker).to have_received(:call).twice
      end
    end
  end
end
