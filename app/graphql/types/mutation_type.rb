# frozen_string_literal: true

Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'
  description 'Base mutation type'

  field :addPublicKey, Mutations::Account::AddPublicKeyMutation
  field :confirmEmail, Mutations::Account::ConfirmEmailMutation
  field :deleteAccount, Mutations::Account::DeleteAccountMutation
  field :removePublicKey, Mutations::Account::RemovePublicKeyMutation
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

  field :addOrganizationMember,
        Mutations::Organization::AddOrganizationMemberMutation
  field :createOrganization,
        Mutations::Organization::CreateOrganizationMutation
  field :deleteOrganization,
        Mutations::Organization::DeleteOrganizationMutation
  field :removeOrganizationMember,
        Mutations::Organization::RemoveOrganizationMemberMutation
  field :saveOrganization, Mutations::Organization::SaveOrganizationMutation

  field :addRepositoryMember,
        Mutations::Repository::AddRepositoryMemberMutation
  field :createRepository, Mutations::Repository::CreateRepositoryMutation
  field :deleteRepository, Mutations::Repository::DeleteRepositoryMutation
  field :removeRepositoryMember,
        Mutations::Repository::RemoveRepositoryMemberMutation
  field :saveRepository, Mutations::Repository::SaveRepositoryMutation

  field :addUrlMapping, Mutations::Repository::AddUrlMappingMutation

  field :setDefaultBranch, Mutations::Repository::Git::SetDefaultBranchMutation

  field :createBranch, Mutations::Repository::Git::CreateBranchMutation
  field :deleteBranch, Mutations::Repository::Git::DeleteBranchMutation

  field :createTag, Mutations::Repository::Git::CreateTagMutation
  field :deleteTag, Mutations::Repository::Git::DeleteTagMutation

  field :commit, Mutations::Repository::Git::CommitMutation
end
