# frozen_string_literal: true

# Directory type for GraphQL
class GitDirectory
  # The commit is *not* the commit of the last change, but the commit that was
  # used to query this directory.
  attr_reader :commit, :name, :path

  def initialize(commit, path, name)
    @commit = commit
    @name = name
    @path = path
  end

  def kind
    'Git::Directory'
  end

  def bringit
    @bringit ||= Bringit::Wrapper.new(@commit.repository.path)
  end
end
