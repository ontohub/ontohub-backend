# frozen_string_literal: true

Types::Organization::RoleEnum = GraphQL::EnumType.define do
  name 'OrganizationRole'
  description 'A users role in an organization'

  value 'read'
  value 'write'
  value 'admin'
end
