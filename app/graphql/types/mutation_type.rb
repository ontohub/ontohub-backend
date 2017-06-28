# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'
  description 'Base mutation type'

  field :createOrganization, Types::OrganizationType do
    description 'Creates a new organization'

    argument :data, !Types::Input::NewOrganizationType do
      description 'The parameters of the new organization'
    end

    resolve Mutations::CreateOrganizationMutation.new
  end

  field :deleteAccount, types.Boolean do
    description <<~DESCRIPTION
      Deletes the account of the currently signed in user.
      Returns `true` if it was successful and `null` if there was an error.
    DESCRIPTION

    argument :password, !types.String do
      description 'Password of the current user to confirm the deletion'
    end

    resource ->(_root, _arguments, context) { context[:current_user] }
    resolve Mutations::DeleteAccountMutation.new
  end

  field :deleteOrganization, types.Boolean do
    description <<~DESCRIPTION
      Deletes an organization.
      Returns `true` if it was successful and `null` if there was an error.
    DESCRIPTION

    argument :id, !types.ID, as: :slug do
      description 'The ID of the organization to delete'
    end

    resource(lambda do |_root, arguments, _context|
      Organization.find(slug: arguments[:slug])
    end)
    resolve Mutations::DeleteOrganizationMutation.new
  end

  field :saveAccount, Types::UserType do
    description 'Updates the current user account'

    argument :data, !Types::Input::UserChangesetType do
      description 'Updated fields of the user'
    end

    argument :password, !types.String do
      description 'Password of the current user to confirm the update'
    end

    resource ->(_root, _arguments, context) { context[:current_user] }
    resolve Mutations::SaveAccountMutation.new
  end

  field :saveOrganization, Types::OrganizationType do
    description 'Updates an organization'

    argument :id, !types.ID, as: :slug do
      description 'ID of the organization to update'
    end

    argument :data, !Types::Input::OrganizationChangesetType do
      description 'Updated fields of the organization'
    end

    resource(lambda do |_root, arguments, _context|
      Organization.find(slug: arguments[:slug])
    end)
    resolve Mutations::SaveOrganizationMutation.new
  end
end
