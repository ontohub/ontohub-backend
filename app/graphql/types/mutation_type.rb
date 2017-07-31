# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Types::MutationType = GraphQL::ObjectType.define do
  # rubocop:enable Metrics/BlockLength
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

  field :createBranch, Mutations::Repository::Git::CreateBranchMutation
  field :deleteBranch, Mutations::Repository::Git::DeleteBranchMutation

  field :createTag, Mutations::Repository::Git::CreateTagMutation
  field :deleteTag, Mutations::Repository::Git::DeleteTagMutation

  field :commit, Mutations::Repository::Git::CommitMutation
end
