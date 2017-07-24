# frozen_string_literal: true

Types::Repository::VisibilityEnum = GraphQL::EnumType.define do
  name 'RepositoryVisibility'
  description 'Possible values for repository visibilities'

  value 'public'
  value 'private'
end
