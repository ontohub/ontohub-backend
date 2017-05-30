# frozen_string_literal: true

if RUBY_ENGINE == 'ruby' # not 'rbx'
  unless defined?(SimpleCov)
    require 'simplecov'
    require 'codecov'
    SimpleCov.formatters = [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Codecov
    ]
    SimpleCov.start do
      # The schema matcher does not need to be tested.
      add_filter 'spec/support/json_schema_matcher.rb'

      # The config of the 'config' gem does not need to be tested.
      add_filter 'config/initializers/config.rb'
    end
  end
end
