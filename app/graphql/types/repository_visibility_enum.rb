# frozen_string_literal: true

Types::RepositoryVisibilityEnum = GraphQL::EnumType.define do
  name 'RepositoryVisibility'
  description 'Possible values for repository visibilities'

  value 'public'
  value 'private'
end
