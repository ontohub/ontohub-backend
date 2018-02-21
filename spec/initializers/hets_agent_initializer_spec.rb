# frozen_string_literal: true

RSpec.describe HetsAgentInitializer do
  let(:bunny_mock) { BunnyMock.new }

  before do
    allow(Sneakers::CONFIG).
      to receive(:[]).
      with(:connection).
      and_return(bunny_mock)
    allow(bunny_mock).to receive(:start).and_call_original
    allow(bunny_mock).to receive(:close).and_call_original
  end

  context 'connection' do
    before do
      HetsAgentInitializer.new.call
    end

    it 'has been started' do
      expect(bunny_mock).to have_received(:start).once
    end

    it 'has been closed' do
      expect(bunny_mock).to have_received(:close).once
    end
  end

  context 'publishing' do
    let(:exchange_data) do
      {
        type: 'x-recent-history',
        arguments: {'x-recent-history-length' => 1},
        durable: true,
      }
    end

    it 'creates the exchange' do
      exchange_name = HetsAgentInitializer::EXCHANGE_NAME
      expect { HetsAgentInitializer.new.call }.
        to change { bunny_mock.exchange_exists?(exchange_name) }.
        from(false).
        to(true)
    end

    it 'creates the exchange with proper arguments' do
      HetsAgentInitializer.new.call
      exchange = bunny_mock.exchanges[HetsAgentInitializer::EXCHANGE_NAME]
      received_exchange_data =
        {
          type: exchange.type,
          arguments: exchange.arguments,
          durable: exchange.durable,
        }
      expect(received_exchange_data).to eq(exchange_data)
    end

    context 'message' do
      let!(:receiver_queue) do
        channel = bunny_mock.channel
        # First, create the exchange
        channel.exchange(HetsAgentInitializer::EXCHANGE_NAME, exchange_data)
        # Then, create the queue and bind it to the exchange
        queue = channel.queue(generate(:username))
        queue.bind(HetsAgentInitializer::EXCHANGE_NAME)
        queue
      end

      before do
        HetsAgentInitializer.new.call
      end

      it 'is sent' do
        expect(receiver_queue.message_count).to eq(1)
      end

      it 'has the correct data' do
        _, _, message = receiver_queue.pop
        expect(message).
          to eq(OntohubBackend::Application.config.hets_version_requirement)
      end
    end
  end
end
