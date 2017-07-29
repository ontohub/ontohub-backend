# frozen_string_literal: true

Types::Git::DirectoryEntryType = GraphQL::ObjectType.define do
  name 'DirectoryEntry'
  description 'A directory entry (directory or file) of a repository'

  field :name, !types.String do
    description 'The name of the entry'
  end

  field :path, !types.String do
    description 'The path of the entry'
  end

  field :type, !types.ID do
    description 'The type of directory entry (directory or file)'
  end
end
