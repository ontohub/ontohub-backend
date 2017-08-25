# frozen_string_literal: true

RSpec.describe ApplicationWorker do
  let(:activejob_base) { class_double('ActiveJob::Base').as_stubbed_const }

  let(:worker) { ApplicationWorker.new }

  it 'executes the base job' do
    expect(activejob_base).to receive(:execute).with('some' => 'value')
    worker.work('{"some": "value"}')
  end
end
