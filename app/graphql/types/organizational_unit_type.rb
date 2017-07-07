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

  field :repositories, !types[Types::RepositoryType] do
    description 'List of repositories owned by this organizational unit'

    argument :limit, types.Int do
      description 'Maximum number of repositories to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n repositories'
      default_value 0
    end
  end
end
