# frozen_string_literal: true

# Worker for the mailers queue
class MailersWorker < ApplicationWorker
  from_queue :mailers, threads: 1, prefetch: 1

  def work(msg)
    job_data = ActiveSupport::JSON.decode(msg)
    ActiveJob::Base.execute job_data
    ack!
  end
end
