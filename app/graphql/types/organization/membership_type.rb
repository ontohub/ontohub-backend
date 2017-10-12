# frozen_string_literal: true

Types::Organization::MembershipType = GraphQL::ObjectType.define do
  name 'OrganizationMembership'
  description 'The membership of a user in an organization'

  field :member, !Types::UserType do
    description 'The member'
  end

  field :organization, !Types::OrganizationType do
    description 'The organization'
  end

  field :role, !Types::Organization::RoleEnum do
    description "The member's role in the organization"
  end
end
