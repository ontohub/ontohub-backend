# frozen_string_literal: true

# Worker for the mailers queue
class MailersWorker < ApplicationWorker
  from_queue 'mailers',
    threads: 1, prefetch: 1, vhost: Settings.rabbitmq.virtual_host
end
