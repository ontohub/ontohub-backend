# frozen_string_literal: true

RSpec.configure do |config|
  # DatabaseCleaner should perform after every example and a full clean before
  # the suite
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    Settings.data_directory.rmtree if Settings.data_directory.exist?
  end

  config.around(:each, :no_transaction) do |example|
    DatabaseCleaner.strategy = :truncation
    example.run
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
    Settings.data_directory.rmtree if Settings.data_directory.exist?
  end
end
