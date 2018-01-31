# frozen_string_literal: true

# Handles the settings values.
class SettingsHandler
  attr_reader :settings

  def initialize(settings)
    @settings = settings
  end

  def call
    SettingsNormalizer.new(settings).call
  end
end
