# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'
  description 'Base mutation type'

  field :confirmEmail, Mutations::Account::ConfirmEmailMutation

  field :createOrganization, Mutations::Organization::CreateOrganizationMutation

  field :createRepository, Types::RepositoryType do
    description 'Creates as new repository'

    argument :data, !Types::Repository::NewType do
      description 'The parameters of the new repository'
    end

    resolve Mutations::CreateRepositoryMutation.new
  end

  field :deleteAccount, Mutations::Account::DeleteAccountMutation

  field :deleteOrganization, Mutations::Organization::DeleteOrganizationMutation

  field :deleteRepository, types.Boolean do
    description 'Deletes a repository'

    argument :id, !types.ID, as: :slug do
      description 'The ID of the repository to delete'
    end

    resource(lambda do |_root, arguments, _context|
      RepositoryCompound.find(slug: arguments[:slug])
    end)
    resolve Mutations::DeleteRepositoryMutation.new
  end

  field :resendConfirmationEmail, Mutations::Account::ResendConfirmationEmailMutation
  field :resendPasswordResetEmail, Mutations::Account::ResendPasswordResetEmailMutation
  field :resendUnlockAccountEmail, Mutations::Account::ResendUnlockAccountEmailMutation
  field :resetPassword, Mutations::Account::ResetPasswordMutation
  field :saveAccount, Mutations::Account::SaveAccountMutation

  field :saveOrganization, Mutations::Organization::SaveOrganizationMutation

  field :saveRepository, Types::RepositoryType do
    description 'Updates a repository'

    argument :id, !types.ID, as: :slug do
      description 'ID of the repository to update'
    end

    argument :data, !Types::Repository::ChangesetType do
      description 'Updated fields of the repository'
    end

    resource(lambda do |_root, arguments, _context|
      RepositoryCompound.find(slug: arguments[:slug])
    end)
    resolve Mutations::SaveRepositoryMutation.new
  end

  field :signIn, Mutations::Account::SignInMutation
  field :signUp, Mutations::Account::SignUpMutation
  field :unlockAccount, Mutations::Account::UnlockAccountMutation
end
