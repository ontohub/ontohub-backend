# frozen_string_literal: true

# Represents a directory in a git repository
class Tree < ActiveModelSerializers::Model
  # Only used for reading
  attr_accessor :commit_id, :entries, :id, :path, :repository

  # rubocop:disable Metrics/AbcSize
  def self.find(args)
    repo = args[:repository] || Repository.find(slug: args[:repository_id])
    repository = RepositoryCompound.wrap(repo)

    opts = {repository: repository, commit_id: args[:branch], path: args[:path]}
    if repository&.git&.path_exists?(args[:branch], args[:path])
      new(**opts, entries: repository&.git&.tree(args[:branch], args[:path]))
    elsif args[:path].sub(%r{\A/+}, '').empty? &&
      repository&.git&.branch_exists?(args[:branch])
      new(**opts, entries: [])
    end
  rescue Rugged::ReferenceError
    nil
  end
  # rubocop:enable Metrics/AbcSize

  def initialize(params)
    super(params)
    branch_exists = git.branch_exists?(commit_id)
    return unless commit_id && (branch_exists || !git.commit(commit_id).nil?)
    if branch_exists
      attributes[:commit_id] = @commit_id = git.branch_sha(commit_id)
    end
    transform_entries
  end

  def git
    @git ||= repository.git
  end

  def url(prefix)
    "#{prefix.sub(%r{/$}, '')}#{url_path}"
  end

  def url_path
    ['', # this empty string adds the leading slash
     repository.to_param,
     'ref', commit_id,
     'tree', path].join('/')
  end

  protected

  def transform_entries
    entries.map! do |entry|
      TreeEntry.new(@commit_id,
                    entry,
                    repository,
                    name: entry.name,
                    path: entry.path,
                    type: entry.file? ? :blobs : :trees)
    end
    attributes[:entries] = entries
  end
end
