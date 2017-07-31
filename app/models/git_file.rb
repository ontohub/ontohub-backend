# frozen_string_literal: true

# File type for GraphQL
class GitFile
  # The commit is *not* the commit of the last change, but the commit that was
  # used to query this file.
  attr_reader :commit, :name, :path

  delegate :size, :loaded_size, to: :blob

  def initialize(commit, path, name: nil, load_all_data: false)
    @path = path
    @commit = commit
    if name.nil?
      # We need to load the name from the blob, so we can load the path as well.
      @name = blob.name
      @path = blob.path
    else
      @name = name
    end
    blob.load_all_data! if load_all_data
  end

  def kind
    'Git::File'
  end

  def content
    blob.data
  end

  def encoding
    blob.binary ? 'base64' : 'plain'
  end

  def gitlab
    @gitlab ||= Gitlab::Git::Wrapper.new(@commit.repository.path)
  end

  protected

  def blob
    @blob ||= gitlab.blob(commit.id, path)
  end
end
