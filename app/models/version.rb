# frozen_string_literal: true

# The Version is a non-persistent object that represents thet version of the
# backend
class Version < ActiveModelSerializers::Model
  # The exception thrown, when the version of the backend could not be
  # determined; be it by using the VERSION file or by git command
  class CouldNotDetermineVersion < StandardError
    def initialize(msg = 'Could not determine backend version.')
      super(msg)
    end
  end

  attr_accessor :commit, :tag, :full, :commits_since_tag

  def initialize(version_string)
    match = /(.+)-(\d+)-g([a-z0-9]{7,40})/.match(version_string)
    super(full: version_string,
          tag: match[1],
          commits_since_tag: match[2].to_i,
          commit: match[3])
  end

  class << self
    def load_version
      version =
        if production?
          read_version_file
        else
          read_version_from_git
        end
      raise CouldNotDetermineVersion, exception_message if version.empty?
      version
    end

    private

    # :nocov:
    def production?
      Rails.env.production?
    end
    # :nocov:

    def test?
      Rails.env.test? && !ENV['ONTOHUB_SYSTEM_TEST']
    end

    # :nocov:
    def read_version_file
      File.read(Rails.root.join('VERSION')).strip
    rescue Errno::ENOENT
      ''
    end
    # :nocov:

    # :nocov:
    def read_version_from_git
      `git describe --long --tags`.strip
    end
    # :nocov:

    def exception_message
      msg = 'Could not determine the backend version. '
      msg +=
        if production?
          'Does the VERSION file exist?'
        else
          'Is this a git repository?'
        end
      msg
    end
  end

  VERSION = load_version unless test?
end
