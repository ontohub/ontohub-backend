# frozen_string_literal: true

class Version < ActiveModelSerializers::Model
  attr_accessor :commit, :tag, :full, :commits_since_tag

  def initialize(version_string)
    match = /(.+)-(\d+)-g([a-z0-9]{7})/.match(version_string)
    super(full: version_string,
          tag: match[1],
          commits_since_tag: match[2].to_i,
          commit: match[3])
  end

  def self.load_version
    if Rails.env == 'production'
      File.read(Rails.root.join('VERSION')).strip
    else
      git_version = `git describe --long --tags`.strip
      raise 'Could not determine backend version via git.' if git_version.empty?
      git_version
    end
  end

  VERSION = load_version
end
