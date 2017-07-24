# frozen_string_literal: true

Types::Organization::NewType = GraphQL::InputObjectType.define do
  name 'NewOrganization'
  description <<~DESCRIPTION
    Contains all fields that are possible to set when creating a new
    organization
  DESCRIPTION

  argument :id, !types.ID, as: :name do
    description 'ID of the new organization'
  end

  argument :displayName, types.String, as: :display_name do
    description 'The name of the organization'
  end

  argument :description, types.String do
    description 'A short description of the organization'
  end
end
