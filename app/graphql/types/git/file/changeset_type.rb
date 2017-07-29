# frozen_string_literal: true

Types::Git::File::ChangesetType = GraphQL::InputObjectType.define do
  name 'FileChangeset'
  description 'A file from a repository'

  argument :action, !Types::Git::Commit::ActionEnum do
    description 'The action to be performed on the file'
  end

  argument :path, !types.String do
    description 'The path of the file inside the repository'
  end

  argument :new_path, types.String do
    description 'The new path of the file for renaming/moving'
  end

  argument :content, types.String do
    description 'The new content of the file'
  end

  argument :encoding, Types::Git::FileEncodingEnum do
    description 'The encoding of the content'
  end
end
