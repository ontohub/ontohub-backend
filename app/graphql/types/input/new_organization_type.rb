# frozen_string_literal: true

Types::Input::NewOrganizationType = GraphQL::InputObjectType.define do
  name 'NewOrganization'

  argument :name, !types.ID, 'Name of the new organization'
  argument :displayName, types.String, nil, as: :display_name
  argument :description, types.String
end
