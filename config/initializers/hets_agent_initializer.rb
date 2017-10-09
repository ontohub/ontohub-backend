# frozen_string_literal: true

# A service class that defines and sends the Hets version requirement.
class HetsAgentIninializer
  EXCHANGE_NAME = 'ex_hets_version_requirement'

  attr_reader :connection

  def initialize
    @connection = Sneakers::CONFIG[:connection]
  end

  def call
    connection.start
    send_version_requirement
  ensure
    connection.close
  end

  protected

  def send_version_requirement
    channel = connection.create_channel
    exchange = channel.exchange(EXCHANGE_NAME,
                     type: 'x-recent-history',
                     durable: true,
                     arguments: {'x-recent-history-length' => 1})
    exchange.
      publish(OntohubBackend::Application.config.hets_version_requirement)
  end
end
