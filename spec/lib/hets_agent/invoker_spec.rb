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

  subject { HetsAgent::Invoker.new(request_collection) }

  before do
    allow(Sneakers).to receive(:publish)
    subject.call
  end

  context 'publishing' do
    it 'was made for every touched file' do
      arguments.each do |argument|
        expect(Sneakers).
          to have_received(:publish).
          with(argument.to_json,
               to_queue: HetsAgent::Invoker::WORKER_QUEUE_NAME)
      end
    end
  end
end
