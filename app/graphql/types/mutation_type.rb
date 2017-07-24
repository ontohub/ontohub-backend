# frozen_string_literal: true

Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'
  description 'Base mutation type'

  field :confirmEmail, Mutations::Account::ConfirmEmailMutation
  field :deleteAccount, Mutations::Account::DeleteAccountMutation
  field :resendConfirmationEmail,
        Mutations::Account::ResendConfirmationEmailMutation
  field :resendPasswordResetEmail,
        Mutations::Account::ResendPasswordResetEmailMutation
  field :resendUnlockAccountEmail,
        Mutations::Account::ResendUnlockAccountEmailMutation
  field :resetPassword, Mutations::Account::ResetPasswordMutation
  field :saveAccount, Mutations::Account::SaveAccountMutation
  field :signIn, Mutations::Account::SignInMutation
  field :signUp, Mutations::Account::SignUpMutation
  field :unlockAccount, Mutations::Account::UnlockAccountMutation

  field :createOrganization,
        Mutations::Organization::CreateOrganizationMutation
  field :deleteOrganization,
        Mutations::Organization::DeleteOrganizationMutation
  field :saveOrganization, Mutations::Organization::SaveOrganizationMutation

  field :createRepository, Mutations::Repository::CreateRepositoryMutation
  field :deleteRepository, Mutations::Repository::DeleteRepositoryMutation
  field :saveRepository, Mutations::Repository::SaveRepositoryMutation
end
