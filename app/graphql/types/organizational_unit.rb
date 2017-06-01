# frozen_string_literal: true

Types::OrganizationalUnit = GraphQL::InterfaceType.define do
  name 'OrganizationalUnit'

  field :id, !types.ID
  field :displayName, types.String
end
