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
end
