# frozen_string_literal: true

Types::Git::DirectoryType = GraphQL::ObjectType.define do
  name 'Directory'
  description 'A directory of a repository'

  implements Types::Git::DirectoryEntryType, inherit: true
end
