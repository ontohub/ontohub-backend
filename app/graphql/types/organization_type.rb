# frozen_string_literal: true

Types::OrganizationType = GraphQL::ObjectType.define do
  name 'Organization'
  interfaces [Types::OrganizationalUnitType]
  description 'Data of an organization'

  field :description, types.String do
    description 'Description of the organization'
  end

  field :members, !types[!Types::UserType] do
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
      organization.members_dataset.order(:slug).
        limit(arguments['limit'], arguments['skip'])
    end)
  end
end
