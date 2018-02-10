# frozen_string_literal: true

RSpec.describe(RefsUpdater) do
  let(:repository) { create(:repository_compound, :not_empty) }
  let(:git) { repository.git }
  let(:user) { repository.owner }
  let(:old_filename) { generate(:filepath) }
  let(:new_filename) { generate(:filepath) }
  let!(:branch1) do
    create(:branch, repository: repository, revision: git.default_branch).name
  end
  let!(:branch2) do
    create(:branch, repository: repository, revision: git.default_branch).name
  end
  let!(:branch1_creation_commit) do
    git.commit(create(:additional_commit, repository: repository,
                                          branch: branch1,
                                          files: [{action: 'create',
                                                   path: old_filename,
                                                   content: generate(:content),
                                                   encoding: 'plain'}]))
  end
  let!(:branch1_renaming_commit) do
    git.commit(create(:additional_commit, repository: repository,
                                          branch: branch1,
                                          files: [{action: 'rename_and_update',
                                                   new_path: new_filename,
                                                   path: old_filename,
                                                   content: generate(:content),
                                                   encoding: 'plain'}]))
  end
  let!(:branch1_deletion_commit) do
    git.commit(create(:additional_commit, repository: repository,
                                          branch: branch1,
                                          files: [{action: 'remove',
                                                   path: new_filename}]))
  end
  let!(:branch2_creation_commit) do
    git.commit(create(:additional_commit, repository: repository,
                                          branch: branch2,
                                          files: [{action: 'create',
                                                   path: old_filename,
                                                   content: generate(:content),
                                                   encoding: 'plain'}]))
  end
  let(:updated_refs) do
    [{'ref' => branch1,
      'before' => git.commit(git.default_branch).id,
      'after' => git.commit(branch1).id},
     {'ref' => branch2,
      'before' => git.commit(git.default_branch).id,
      'after' => git.commit(branch2).id}]
  end
  subject { RefsUpdater.new(user, repository, updated_refs) }

  # Clean the state. We want to test if the described mutation creates each
  # FileVersion. The :additional_commit and :repository_compound factories have
  # created FileVersions along the way.
  before do
    subject
    FileVersion.each(&:destroy)
  end

  shared_examples 'sending a ProcecessCommitJob' do
    it 'is enqueued' do
      expect { subject.call }.
        to have_enqueued_job(ProcessCommitJob).
        with(repository.pk, commit_sha)
    end
  end

  context 'ProcessCommitJob for' do
    context 'the file-creating commit of branch1' do
      include_examples 'sending a ProcecessCommitJob' do
        let(:commit_sha) { branch1_creation_commit.id }
      end
    end

    context 'the file-renaming commit of branch1' do
      include_examples 'sending a ProcecessCommitJob' do
        let(:commit_sha) { branch1_renaming_commit.id }
      end
    end

    context 'the file-deleting commit of branch1' do
      include_examples 'sending a ProcecessCommitJob' do
        let(:commit_sha) { branch1_deletion_commit.id }
      end
    end

    context 'the file-creating commit of branch2' do
      include_examples 'sending a ProcecessCommitJob' do
        let(:commit_sha) { branch2_creation_commit.id }
      end
    end
  end

  shared_examples 'creating a FileVersion' do
    before { subject.call }

    it 'creates a FileVersion' do
      expect(FileVersion.first(repository_id: repository.pk,
                               commit_sha: commit_sha,
                               path: path)).not_to be(nil)
    end
  end

  context 'FileVersions' do
    context 'on branch1_creation_commit' do
      include_examples 'creating a FileVersion' do
        let(:commit_sha) { branch1_creation_commit.id }
        let(:path) { old_filename }
      end
    end

    context 'on branch1_renaming_commit' do
      include_examples 'creating a FileVersion' do
        let(:commit_sha) { branch1_renaming_commit.id }
        let(:path) { new_filename }
      end
    end

    it 'does not create a FileVersion for the deleted file' do
      subject.call
      commit_sha = branch1_deletion_commit.id
      path = new_filename
      expect(FileVersion.first(repository_id: repository.pk,
                               commit_sha: commit_sha,
                               path: path)).to be(nil)
    end

    context 'on branch2_creation_commit' do
      include_examples 'creating a FileVersion' do
        let(:commit_sha) { branch2_creation_commit.id }
        let(:path) { old_filename }
      end
    end
  end
end
