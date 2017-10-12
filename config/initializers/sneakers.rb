# frozen_string_literal: true

if Rails.env.test?
  require Rails.root.join('spec/support/bunnymock_recent_history_exchange.rb')
  Sneakers.configure(connection: BunnyMock.new)
else
  # :nocov:
  Sneakers.configure(connection: Bunny.new)
  Sneakers.logger.level = Logger::WARN
  # :nocov:
end
