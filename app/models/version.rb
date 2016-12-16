# frozen_string_literal: true

class Version < ActiveModelSerializers::Model

  class CouldNotDetermineVersion < StandardError
    def initialize(msg = 'Could not determine backend version.')
      super(msg)
    end
  end

  attr_accessor :commit, :tag, :full, :commits_since_tag

  def initialize(version_string)
    match = /(.+)-(\d+)-g([a-z0-9]{7})/.match(version_string)
    super(full: version_string,
          tag: match[1],
          commits_since_tag: match[2].to_i,
          commit: match[3])
  end

  def self.production?
    Rails.env.production?
  end

  def self.read_version_file
    File.read(Rails.root.join('VERSION')).strip
  rescue Errno::ENOENT => _
    ""
  end

  def self.read_version_from_git
    `git describe --long --tags`.strip
  end

  def self.load_version
    version = production? ? read_version_file : read_version_from_git
    exception_text = production? ? 'Does the VERSION file exist?' : 'Is this a git repository?'
    raise CouldNotDetermineVersion, 'Could not determin the backend version. ' + exception_text if version.empty?
    version
  end

  VERSION = load_version
end
