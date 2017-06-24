# frozen_string_literal: true

Types::Input::OrganizationChangesetType = GraphQL::InputObjectType.define do
  name 'OrganizationChangeset'

  argument :displayName, types.String, nil, as: :display_name
  argument :description, types.String
end
