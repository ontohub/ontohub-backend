# frozen_string_literal: true

connection = Sneakers::CONFIG[:connection]
begin
  connection.start
  channel = connection.create_channel
  queue = channel.queue(HetsAgent::Invoker::WORKER_QUEUE_NAME,
                        durable: true,
                        auto_delete: false)
  queue.purge
ensure
  connection.close
end
