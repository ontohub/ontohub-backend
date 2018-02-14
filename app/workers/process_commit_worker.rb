# frozen_string_literal: true

# Worker for the commit queue
class ProcessCommitWorker < ApplicationWorker
  from_queue 'process_commit', threads: 1, prefetch: 1,
                               vhost: Settings.rabbitmq.virtual_host
end
