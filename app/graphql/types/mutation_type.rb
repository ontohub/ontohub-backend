# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'
  description 'Base mutation type'

  field :confirmEmail, Types::SessionTokenType do
    description 'Confirms the email address of a user'

    argument :token, !types.String do
      description 'The confirmation token from the confirmation email'
    end

    resolve Mutations::ConfirmEmailMutation.new
  end

  field :createOrganization, Types::OrganizationType do
    description 'Creates a new organization'

    argument :data, !Types::Input::NewOrganizationType do
      description 'The parameters of the new organization'
    end

    resolve Mutations::CreateOrganizationMutation.new
  end

  field :createRepository, Types::RepositoryType do
    description 'Creates as new repository'

    argument :data, !Types::Input::NewRepositoryType do
      description 'The parameters of the new repository'
    end

    resolve Mutations::CreateRepositoryMutation.new
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

  field :resendConfirmationEmail, !types.Boolean do
    description 'Resends the confirmation email to a user'

    argument :email, !types.String do
      description 'The email address of the user'
    end

    resolve Mutations::ResendConfirmationEmailMutation.new
  end

  field :resendPasswordResetEmail, !types.Boolean do
    description 'Resends the password reset email to a user'

    argument :email, !types.String do
      description 'The email address of the user'
    end

    resolve Mutations::ResendPasswordResetEmailMutation.new
  end

  field :resendUnlockAccountEmail, !types.Boolean do
    description 'Resends the unlock account email to a user'

    argument :email, !types.String do
      description 'The email address of the user'
    end

    resolve Mutations::ResendUnlockAccountEmailMutation.new
  end

  field :resetPassword, Types::SessionTokenType do
    description "Resets a user's password"

    argument :password, !types.String do
      description 'The new password'
    end

    argument :token, !types.String do
      description 'The reset token from the password reset email'
    end

    resolve Mutations::ResetPasswordMutation.new
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

  field :saveRepository, Types::RepositoryType do
    description 'Updates a repository'

    argument :id, !types.ID, as: :slug do
      description 'ID of the repository to update'
    end

    argument :data, !Types::Input::RepositoryChangesetType do
      description 'Updated fields of the repository'
    end

    resource(lambda do |_root, arguments, _context|
      RepositoryCompound.find(slug: arguments[:slug])
    end)
    resolve Mutations::SaveRepositoryMutation.new
  end

  field :signIn, Types::SessionTokenType do
    description 'Signs in a user'

    argument :username, !types.String do
      description "The user's name"
    end

    argument :password, !types.String do
      description "The user's password"
    end

    resolve Mutations::SignInMutation.new
  end

  field :signUp, Types::SessionTokenType do
    description 'Signs up a user'

    argument :user, !Types::Input::NewUserType do
      description "The new user's data"
    end

    argument :captcha, !types.String do
      description 'A reCAPTCHA token'
    end

    resolve Mutations::SignUpMutation.new
  end

  field :unlockAccount, Types::SessionTokenType do
    description 'Unlocks a locked user account'

    argument :token, !types.String do
      description 'The unlock account token from the unlock account email'
    end

    resolve Mutations::UnlockAccountMutation.new
  end
end
