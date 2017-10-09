# frozen_string_literal: true

module HetsAgent
  # A service class that finds the new files of a commit and invokes the
  # HetsAgent to analyze them.
  class Invoker
    WORKER_QUEUE_NAME =
      "hets #{OntohubBackend::Application.config.hets_version_requirement}"

    attr_reader :connection, :request_collection

    def initialize(request_collection)
      @request_collection = request_collection
      @connection = Sneakers::CONFIG[:connection]
    end

    def call
      connection.start
      queue = create_worker_queue(connection)
      request_collection.each do |request|
        queue.publish(request.to_json)
      end
    ensure
      connection.close
    end

    protected

    def create_worker_queue(connection)
      channel = connection.create_channel
      channel.queue(WORKER_QUEUE_NAME,
                    durable: true,
                    auto_delete: false)
    end
  end
end
