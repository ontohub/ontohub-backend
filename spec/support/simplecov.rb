# frozen_string_literal: true

if RUBY_ENGINE == 'ruby' # not 'rbx'
  unless defined?(SimpleCov)
    require 'simplecov'
    SimpleCov.start do
      # The schema matcher does not need to be tested.
      add_filter 'spec/support/json_schema_matcher.rb'

      # The config of the 'config' gem does not need to be tested.
      add_filter 'config/initializers/config.rb'
    end
    require 'codecov'
    formatters = [SimpleCov::Formatter::HTMLFormatter]
    formatters << SimpleCov::Formatter::Codecov if ENV['CI']
    SimpleCov.formatters = formatters
  end
end
