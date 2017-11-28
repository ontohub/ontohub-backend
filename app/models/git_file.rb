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
    if name.nil? # The name is only nil in a file query
      load_name_and_path_from_blob
    else # The name is supplied in a directory query
      @name = name
    end
    blob&.load_all_data! if load_all_data
  end

  def kind
    'Git::File'
  end

  def content
    blob&.binary ? Base64.encode64(blob&.data) : blob&.data
  end

  def encoding
    blob&.binary ? 'base64' : 'plain'
  end

  def bringit
    @bringit ||= Bringit::Wrapper.new(@commit.repository.path)
  end

  def exist?
    check_existance unless @existance_checked
    @exist
  end

  protected

  def blob
    @blob ||= bringit.blob(commit.id, path)
  end

  # We need to load the name from the blob. Since we need to load the blob for
  # it, we can load the path as well.
  def load_name_and_path_from_blob
    check_existance
    return unless blob
    @name = blob.name
    @path = blob.path
  end

  # Checks the existance by loading the blob
  def check_existance
    @existance_checked = true
    @exist = !blob.nil?
  end
end
