# frozen_string_literal: true

require 'ostruct'

RSpec.describe HetsAgent::Invoker do
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

  let(:exchange) { subject.send(:exchange) }
  let(:queue) do
    exchange.channel.queue(HetsAgent::Invoker::WORKER_QUEUE_NAME).tap do |queue|
      queue.bind(exchange, routing_key: HetsAgent::Invoker::WORKER_QUEUE_NAME)
    end
  end

  subject { HetsAgent::Invoker.new(request_collection) }

  before do
    queue
    subject.call
  end

  context 'publishing' do
    it 'was made for every touched file' do
      arguments.each do |argument|
        payload = queue.pop
        expect(payload[2]).to eq(argument.to_json)
      end
    end
  end
end
