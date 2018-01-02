# frozen_string_literal: true

Types::RepositoryWithoutGitType = GraphQL::ObjectType.define do
  name 'RepositoryWithoutGit'
  description 'Data of a repository without git'

  implements Types::BaseRepositoryType, inherit: true
end
