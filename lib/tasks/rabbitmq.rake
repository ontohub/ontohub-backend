# frozen_string_literal: true

QUEUES = %w(
  git_clone
  git_pull
  hets\ >=\ 0.100.0
  indexing
  mailers
  post_process_hets
  process_commit
)

namespace :rabbitmq do
  desc "Purge all rabbitmq queues"
  task :purge do
    next if Rails.env.test?
    connection = Bunny.new(username: Settings.rabbitmq.username,
                           password: Settings.rabbitmq.password,
                           host: Settings.rabbitmq.host,
                           port: Settings.rabbitmq.port,
                           virtual_host: Settings.rabbitmq.virtual_host)
    connection.start
    channel = connection.create_channel
    QUEUES.each do |queue|
      channel.queue(queue, durable: true).purge
    end
    connection.close
  end
end
