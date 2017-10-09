# frozen_string_literal: true

RSpec.describe HetsAgent::AnalysisRequestCollection do
  let(:repository) { create(:repository_compound, :not_empty) }
  let(:files_count) { 2 }
  let(:commit_sha) do
    files = (1..files_count).map do
      {path: generate(:filepath),
       content: generate(:content),
       encoding: 'plain',
       action: 'create'}
    end
    create(:additional_commit,
           repository: repository,
           files: files)
  end

  subject do
    HetsAgent::AnalysisRequestCollection.new(repository.id, commit_sha)
  end

  context 'requests' do
    it 'as many requests exist as files were touched' do
      expect(subject.requests.length).to eq(files_count)
    end

    it 'contains one request for every touched file' do
      file_versions = FileVersion.where(commit_sha: commit_sha).all

      expect do
        subject.each do |request|
          file_versions.reject! do |file_version|
            request[:arguments][:file_version_id] == file_version.id &&
              request[:arguments][:file_path] == file_version.path
          end
        end
      end.
        to change { file_versions.length }.
        from(files_count).
        to(0)
    end

    it 'has the correct request format except for file_path/file_version_id' do
      subject.each do |request|
        expect(request).
          to include(action: 'analysis',
                     arguments: include(server_url: Settings.server_url,
                                        repository_slug: repository.to_param,
                                        revision: commit_sha,
                                        url_mappings: []))
      end
    end
  end

  context 'each' do
    it 'is delegated to requests' do
      direct = []
      indirect = []
      subject.each { |request| direct << request }
      subject.requests.each { |request| indirect << request }
      expect(direct).to eq(indirect)
    end
  end
end
