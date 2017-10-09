# frozen_string_literal: true

connection = Sneakers::CONFIG[:connection]
begin
  connection.start
  channel = connection.create_channel

  channel.queue(HetsAgent::Invoker::WORKER_QUEUE_NAME,
                durable: true,
                auto_delete: false).purge

  channel.queue('post_process_hets',
                durable: true,
                auto_delete: false).purge
ensure
  connection.close
end
