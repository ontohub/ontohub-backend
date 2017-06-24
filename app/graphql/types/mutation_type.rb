# frozen_string_literal: true

Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'

  field :createOrganization, Types::OrganizationType do
    argument :data, !Types::Input::NewOrganizationType
    resolve Mutations::CreateOrganizationMutation
  end
end
