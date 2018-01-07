# frozen_string_literal: true

# Worker for the mailers queue
class MailersWorker < ApplicationWorker
  from_queue "#{Settings.rabbitmq.prefix}_mailers", threads: 1, prefetch: 1
end
