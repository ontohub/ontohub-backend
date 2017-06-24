# frozen_string_literal: true

Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'

  field :createOrganization, Types::OrganizationType do
    argument :data, !Types::Input::NewOrganizationType
    resolve Mutations::CreateOrganizationMutation.new
  end

  field :deleteOrganization, !types.Boolean do
    argument :id, !types.ID, nil, as: :slug
    resolve Mutations::DeleteOrganizationMutation.new
  end

  field :saveOrganization, Types::OrganizationType do
    argument :id, !types.ID, nil, as: :slug
    argument :data, !Types::Input::OrganizationChangesetType
    resolve Mutations::SaveOrganizationMutation.new
  end

  field :saveAccount, Types::UserType do
    argument :data, !Types::Input::UserChangesetType
    argument :password, !types.String
    resolve Mutations::SaveAccountMutation.new
  end
end
