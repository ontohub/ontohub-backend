# frozen_string_literal: true

module HetsAgent
  # A service class that finds the new files of a commit and invokes the
  # HetsAgent to analyze them.
  class Invoker
    WORKER_QUEUE_NAME =
      "#{Settings.rabbitmq.prefix}_hets #{OntohubBackend::Application.config.hets_version_requirement}"

    attr_reader :request_collection

    def initialize(request_collection)
      @request_collection = request_collection
    end

    def call
      request_collection.each do |request|
        Sneakers.publish(request.to_json, to_queue: WORKER_QUEUE_NAME)
      end
    end
  end
end
