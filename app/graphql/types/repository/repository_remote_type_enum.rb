# frozen_string_literal: true

Types::Repository::RepositoryRemoteTypeEnum = GraphQL::EnumType.define do
  name 'RepositoryRemoteTypeEnum'
  description 'Possible values for repository remote types'

  value 'fork', 'A copy of a repository'
  value 'mirror',
    'A read-only copy of a repository that is synchronized periodically'
end
