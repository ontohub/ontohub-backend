# frozen_string_literal: true

# Represents an entry of the git tree. Does not load the underlying blob/tree.
class TreeEntry < ActiveModelSerializers::Model
  attr_accessor :name, :path, :type
  def initialize(commit_id, gitlab_tree, repository, params)
    super(params)
    @commit_id = commit_id
    @repository = repository
    @gitlab_tree = gitlab_tree
  end
end
