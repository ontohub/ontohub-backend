# frozen_string_literal: true

# Worker for the commit queue
class ProcessCommitWorker < ApplicationWorker
  from_queue "#{Settings.rabbitmq.prefix}_process_commit",
    threads: 1, prefetch: 1
end
