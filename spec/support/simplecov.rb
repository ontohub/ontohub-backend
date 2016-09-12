# frozen_string_literal: true

unless defined?(Coveralls)
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter,
  ]
end
