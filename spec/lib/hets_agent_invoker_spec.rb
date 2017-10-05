# frozen_string_literal: true

RSpec.describe HetsAgentIninializer do
  let(:bunny_mock) { BunnyMock.new }
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

  subject { HetsAgentInvoker.new(repository.id, commit_sha) }

  before do
    allow(Sneakers::CONFIG).
      to receive(:[]).
      with(:connection).
      and_return(bunny_mock)
    allow(bunny_mock).to receive(:start).and_call_original
    allow(bunny_mock).to receive(:close).and_call_original
    subject.call
  end

  context 'connection' do
    it 'has been started' do
      expect(bunny_mock).to have_received(:start)
    end

    it 'has been closed' do
      expect(bunny_mock).to have_received(:close)
    end
  end

  context 'publishing' do
    let(:receive_proc) do
      lambda do |expectation|
        channel = bunny_mock.create_channel
        queue = channel.queue(HetsAgentInvoker::WORKER_QUEUE_NAME)
        queue.subscribe(block: true, timeout: 1) do |_, _, message|
          expectation.call(JSON.parse(message))
        end
      end
    end

    it 'was made as many times as files were touched' do
      channel = bunny_mock.create_channel
      queue = channel.queue(HetsAgentInvoker::WORKER_QUEUE_NAME)
      expect(queue.message_count).to eq(files_count)
    end

    it 'was made for every touched file' do
      file_versions = FileVersion.where(commit_sha: commit_sha).all
      expect(file_versions).not_to be_empty

      receive_proc.call(lambda do |message|
        file_versions.reject! do |file_version|
          message['arguments']['file_version_id'] == file_version.id &&
            message['arguments']['file_path'] == file_version.path
        end
      end)

      expect(file_versions).to be_empty
    end

    it 'has the correct message format except for file_path/file_version_id' do
      receive_proc.call(lambda do |message|
        expect(message).
          to include('action' => 'analysis',
                     'arguments' =>
                       include('server_url' => Settings.server_url,
                               'repository_slug' => repository.to_param,
                               'revision' => commit_sha,
                               'url_mappings' => {}))
      end)
    end
  end
end
