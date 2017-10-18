# frozen_string_literal: true

Types::OrganizationType = GraphQL::ObjectType.define do
  name 'Organization'
  interfaces [Types::OrganizationalUnitType]
  description 'Data of an organization'

  field :description, types.String do
    description 'Description of the organization'
  end

  field :memberships do
    type !types[!Types::Organization::MembershipType]
    description "List of the organization's memberships"

    argument :limit, types.Int do
      description 'Maximum number of memberships to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n memberships'
      default_value 0
    end

    argument :role, Types::Organization::RoleEnum do
      description 'Filter the users by the membership role'
    end

    resolve(lambda do |organization, arguments, _context|
      dataset = OrganizationMembership.where(organization_id: organization.id)
      dataset = dataset.where(role: arguments['role']) if arguments['role']
      dataset.join(:organizational_units, id: :member_id).
        order(Sequel[:organizational_units][:slug]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :permissions, Types::Organization::PermissionsType do
    description "The current_user's permissions for this organization"

    resolve(lambda do |organization, _arguments, context|
      return unless context[:current_user]
      organization
    end)
  end
end
