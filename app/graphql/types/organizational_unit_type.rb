# frozen_string_literal: true

Types::OrganizationalUnitType = GraphQL::InterfaceType.define do
  name 'OrganizationalUnit'
  description 'Common fields of organizational units'

  field :id, !types.ID do
    description 'ID of the organizational unit'
    property :to_param
  end

  field :displayName, types.String do
    description 'Display name of the organizational unit'
    property :display_name
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

    resolve(lambda do |organizational_unit, arguments, _context|
      limit = arguments[:limit] || target.arguments['limit'].default_value
      skip = arguments[:skip] || target.arguments['skip'].default_value
      organizational_unit.repositories_dataset.limit(limit, skip)
    end)
  end
end
