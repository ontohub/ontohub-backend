# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Types::OrganizationalUnitType = GraphQL::InterfaceType.define do
  # rubocop:enable Metrics/BlockLength
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

  field :repositories, !types[!Types::RepositoryType] do
    description 'List of repositories owned by this organizational unit'

    argument :limit, types.Int do
      description 'Maximum number of repositories to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n repositories'
      default_value 0
    end

    resource(lambda do |org_unit, _arguments, _context|
      org_unit.repositories_dataset
    end)

    resolve(lambda do |repositories, arguments, _context|
      repositories.order(:slug).
        limit(arguments['limit'], arguments['skip']).
        map { |r| RepositoryCompound.wrap(r) }
    end)
  end
end
