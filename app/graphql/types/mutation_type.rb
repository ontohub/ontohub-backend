# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'

  field :createOrganization, Types::OrganizationType do
    argument :data, !Types::Input::NewOrganizationType
    resolve Mutations::CreateOrganizationMutation.new
  end

  field :deleteOrganization, types.Boolean do
    argument :id, !types.ID, nil, as: :slug
    resource ->(_obj, args, _ctx) { Organization.find(slug: args[:slug]) }
    resolve Mutations::DeleteOrganizationMutation.new
  end

  field :deleteAccount, types.Boolean do
    argument :password, !types.String
    resource ->(_obj, _args, ctx) { ctx[:current_user] }
    resolve Mutations::DeleteAccountMutation.new
  end

  field :saveOrganization, Types::OrganizationType do
    argument :id, !types.ID, nil, as: :slug
    argument :data, !Types::Input::OrganizationChangesetType
    resource ->(_obj, args, _ctx) { Organization.find(slug: args[:slug]) }
    resolve Mutations::SaveOrganizationMutation.new
  end

  field :saveAccount, Types::UserType do
    argument :data, !Types::Input::UserChangesetType
    argument :password, !types.String
    resource ->(_obj, _args, ctx) { ctx[:current_user] }
    resolve Mutations::SaveAccountMutation.new
  end
end
# rubocop:enable Metrics/BlockLength
