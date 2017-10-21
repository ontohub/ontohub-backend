# frozen_string_literal: true

RSpec.describe HetsAgent::ReanalysisRequestCollection do
  let(:repository) { create(:repository_compound, :not_empty) }
  let(:file_version) { create(:file_version, repository: repository) }

  subject do
    HetsAgent::ReanalysisRequestCollection.new(file_version)
  end

  context 'requests' do
    it 'contains exactly one request' do
      expect(subject.requests.length).to eq(1)
    end

    it 'contains one request for every touched file' do
      correct_arguments = subject.map do |request|
        request[:arguments][:file_version_id] == file_version.id &&
          request[:arguments][:file_path] == file_version.path &&
          request[:arguments][:revision] == file_version.commit_sha
      end
      expect(correct_arguments).to eq([true])
    end

    it 'has the correct request format except for file_path/file_version_id' do
      subject.each do |request|
        expect(request).
          to include(action: 'analysis',
                     arguments: include(server_url: Settings.server_url,
                                        repository_slug: repository.to_param,
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
