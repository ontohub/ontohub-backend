# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Types::OrganizationType = GraphQL::ObjectType.define do
  name 'Organization'
  interfaces [Types::OrganizationalUnitType]
  description 'Data of an organization'

  field :id, !types.ID do
    description 'ID of the organization'
    property :to_param
  end

  field :displayName, types.String do
    description 'Display name of the organization'
    property :display_name
  end

  field :description, types.String do
    description 'Description of the organization'
  end

  field :members, !types[Types::UserType] do
    description 'List of members'

    argument :limit, types.Int do
      description 'Maximum number of members to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n members'
      default_value 0
    end

    resolve(lambda do |organization, arguments, _context|
      organization.members_dataset.limit(arguments[:limit], arguments[:skip])
    end)
  end

  field :repositories, !types[Types::RepositoryType] do
    description 'List of repositories owned by this organization'

    argument :limit, types.Int do
      description 'Maximum number of repositories to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n repositories'
      default_value 0
    end

    resolve(lambda do |organization, arguments, _context|
      organization.repositories_dataset.
        limit(arguments[:limit], arguments[:skip])
    end)
  end
end
