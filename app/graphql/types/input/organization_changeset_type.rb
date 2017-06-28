# frozen_string_literal: true

Types::Input::OrganizationChangesetType = GraphQL::InputObjectType.define do
  name 'OrganizationChangeset'
  description <<~DESCRIPTION
    Contains all fields of an organization that can be changed
  DESCRIPTION

  argument :displayName, types.String, as: :display_name do
    description 'The name of the organization'
  end

  argument :description, types.String do
    description 'A short description of the organization'
  end
end
