# frozen_string_literal: true

# :nocov:
if Rails.env.development?
  require 'ostruct'

  # The Rails integration of Config adds a before_action to
  # ActionController::Base only in the development environment that invokes
  # ::Config.reload! and cannot be turned off. This monkey-patch makes
  # ::Config.reload!  append the actions that post-process the Settings.
  module Config
    original_definition_of_normalize_path = method(:reload!)

    define_singleton_method(:reload!) do
      settings = original_definition_of_normalize_path.call
      SettingsHandler.new(settings).call
      settings
    end
  end
end
# :nocov:
