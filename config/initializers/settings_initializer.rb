# frozen_string_literal: true

# Initializes the settings, e.g. creates directories.
class SettingsInitializer
  attr_reader :settings

  def initialize(settings)
    @settings = settings
  end

  def call
    create_directories
  end

  protected

  def create_directories
    [@settings.data_directory].each do |dir|
      FileUtils.mkdir_p(dir) unless File.exist?(dir)
    end
  end
end
