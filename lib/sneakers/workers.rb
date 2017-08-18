# frozen_string_literal: true

module Sneakers
  # Module to contain the created Worker classes
  # This is an easy way to create worker classes that listen to a given queue,
  # since the normal Sneakers worker only listens to the `default` queue.
  # TEMPORARY: We will want to have greater control over how many threads a
  # worker uses, so this code might become obsolete when we switch to
  # explicitly writing worker classes
  module Workers
    def self.create(queue_name)
      klass = Class.new do
        include Sneakers::Worker
        from_queue queue_name

        def work(msg)
          job_data = ActiveSupport::JSON.decode(msg)
          ActiveJob::Base.execute job_data
          ack!
        end
      end
      Sneakers::Workers.const_set("#{queue_name}Worker".camelize, klass)
    end
  end
end
