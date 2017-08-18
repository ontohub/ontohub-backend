# frozen_string_literal: true

# Normalizes the settings values.
class SettingsNormalizer
  attr_reader :settings

  def initialize(settings)
    @settings = settings
  end

  def call
    normalize_paths
    normalize_worker_groups
  end

  protected

  def normalize_paths
    @settings.data_directory = normalize_path(@settings.data_directory)
  end

  def normalize_path(path)
    return unless path

    path = path.to_s

    # Replace multiple slashes by only one.
    path = path.gsub(%r{/+}, '/')

    # Remove trailing slash
    path = path.gsub(%r{/\z}, '')

    path = Pathname.new(path)

    # Expand relative paths (e.g. foo/../bar to bar)
    path.relative_path_from(Pathname.new('')) if path.relative?

    Rails.root.join(path)
  end

  def normalize_worker_groups
    groups = @settings.sneakers
    groups.map do |group|
      classes = group.classes
      classes = [classes] unless classes.is_a?(Array)
      group.classes = classes
      group
    end
  end
end
