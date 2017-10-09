# frozen_string_literal: true

require 'ostruct'

RSpec.describe HetsAgent::Invoker do
  let(:bunny_mock) { BunnyMock.new }

  let(:arguments) { [{'arg' => 'ARG1'}, {'arg' => 'ARG2'}] }

  let(:request_collection) do
    result = OpenStruct.new(requests: arguments)
    result.define_singleton_method(:each) do |&block|
      result.requests.each do |request|
        block.call(request)
      end
    end
    result
  end

  subject { HetsAgent::Invoker.new(request_collection) }

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
        queue = channel.queue(HetsAgent::Invoker::WORKER_QUEUE_NAME)
        queue.subscribe(block: true, timeout: 1) do |_, _, message|
          expectation.call(JSON.parse(message))
        end
      end
    end

    it 'was made as many times as files were touched' do
      channel = bunny_mock.create_channel
      queue = channel.queue(HetsAgent::Invoker::WORKER_QUEUE_NAME)
      expect(queue.message_count).to eq(arguments.count)
    end

    it 'was made for every touched file' do
      received_arguments = []

      receive_proc.call(lambda do |message|
        received_arguments << message
      end)

      expect(received_arguments).to match_array(arguments)
    end
  end
end
