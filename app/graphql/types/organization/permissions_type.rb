# frozen_string_literal: true

Types::Organization::PermissionsType = GraphQL::ObjectType.define do
  name 'OrganizationPermissions'
  description 'Holds permission information for an organization'

  field :role, !Types::Organization::RoleEnum do
    description "The user's role in the organization"

    resolve(lambda do |organization, _arguments, context|
      OrganizationMembership.first(organization_id: organization.id,
                                   member_id: context[:current_user].id).role
    end)
  end
end
