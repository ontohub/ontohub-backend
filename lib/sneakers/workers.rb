# frozen_string_literal: true

module Sneakers
  # Module to contain the created Worker classes
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
      Sneakers::Workers.const_set((queue_name.to_s + 'Worker').camelize, klass)
    end
  end
end
