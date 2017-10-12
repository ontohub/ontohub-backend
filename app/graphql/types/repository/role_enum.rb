# frozen_string_literal: true

Types::Repository::RoleEnum = GraphQL::EnumType.define do
  name 'RepositoryRole'
  description 'Possible values for repository roles'

  value 'read'
  value 'write'
  value 'admin'
end
