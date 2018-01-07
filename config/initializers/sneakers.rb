# frozen_string_literal: true

if Rails.env.test?
  require Rails.root.join('spec/support/bunnymock_recent_history_exchange.rb')
  Sneakers.configure(connection: BunnyMock.new,
                     exchange: Settings.rabbitmq.exchange)
else
  # :nocov:
  Sneakers.configure(connection: Bunny.new(username: Settings.rabbitmq.username,
                                           password: Settings.rabbitmq.password,
                                           host: Settings.rabbitmq.host,
                                           port: Settings.rabbitmq.port),
                     exchange: Settings.rabbitmq.exchange)
  Sneakers.logger.level = Logger::ERROR
  # :nocov:
end
