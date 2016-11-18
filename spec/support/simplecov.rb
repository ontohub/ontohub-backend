# frozen_string_literal: true

unless defined?(Coveralls)
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter,
  ]
  SimpleCov.start do
    # The schema matcher does not need to be tested.
    add_filter 'spec/support/json_schema_matcher.rb'

    # The config of the 'config' gem does not need to be tested.
    add_filter 'config/initializers/config.rb'
  end
end
