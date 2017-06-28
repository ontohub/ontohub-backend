# frozen_string_literal: true

Types::OrganizationalUnitType = GraphQL::InterfaceType.define do
  name 'OrganizationalUnit'
  description 'Common fields of organizational units'

  field :id, !types.ID do
    description 'ID of the organizational unit'
  end

  field :displayName, types.String do
    description 'Display name of the organizational unit'
  end
end
