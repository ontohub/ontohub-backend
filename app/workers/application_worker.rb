# frozen_string_literal: true

# Base class for all workers
class ApplicationWorker
  include Sneakers::Worker
  from_queue "#{Settings.rabbitmq.prefix}_default"

  def work(msg)
    job_data = ActiveSupport::JSON.decode(msg)
    ActiveJob::Base.execute job_data
    ack!
  end
end
