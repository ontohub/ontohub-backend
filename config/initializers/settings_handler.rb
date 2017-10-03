# frozen_string_literal: true

# Handles the settings values.
class SettingsHandler
  attr_reader :settings

  def initialize(settings)
    @settings = settings
  end

  def call
    SettingsPresenceValidator.new(settings).call
    SettingsNormalizer.new(settings).call
    SettingsInitializer.new(settings).call
    SettingsValidator.new(settings).call
  end
end
