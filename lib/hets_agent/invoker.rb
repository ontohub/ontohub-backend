# frozen_string_literal: true

module HetsAgent
  # A service class that finds the new files of a commit and invokes the
  # HetsAgent to analyze them.
  class Invoker
    WORKER_QUEUE_NAME =
      "hets #{OntohubBackend::Application.config.hets_version_requirement}"

    attr_reader :request_collection

    def initialize(request_collection)
      @request_collection = request_collection
    end

    def call
      connection = Sneakers::CONFIG[:connection]
      connection.start unless connection.open?
      channel = connection.create_channel
      exchange = channel.direct('sneakers', durable: true)

      request_collection.each do |request|
        exchange.publish(request.to_json, routing_key: WORKER_QUEUE_NAME)
      end
    ensure
      connection.close
    end
  end
end
