# frozen_string_literal: true

require 'ostruct'

module Mutations
  module Account
    ResetPasswordMutation = GraphQL::Field.define do
      type Types::User::SessionTokenType
      description "Resets a user's password"

      argument :password, !types.String do
        description 'The new password'
      end

      argument :token, !types.String do
        description 'The reset token from the password reset email'
      end

      authorize! :recover_password, policy: :password

      resolve ResetPasswordResolver.new
    end

    # GraphQL mutation to confirm a user's email address
    class ResetPasswordResolver < AbstractDeviseResolver
      # Note, that this does not directly use Devise controller actions to
      # perform the mutation. Devise's corresponding controller action, which
      # would normally be called, performs various things we don't need for an
      # API only application (including setting flash messages, rendering the
      # response, bypassing the signin). This code mirrors what is left of the
      # that action after stripping the rest away. Make sure that this code is
      # updated if Devise adds relevant code to the controller action.
      #
      # For reference, see the V2::Users::PasswordController#recover_password
      # and
      # https://github.com/plataformatec/devise/blob/7a44233fb9439e7cc4d1503b14f02a1d9f6da7b9/app/controllers/devise/passwords_controller.rb#L31-L49
      def call(_root, arguments, context)
        setup_devise(context)
        user = User.
          reset_password_by_token(password: arguments['password'],
                                  reset_password_token: arguments['token'])
        if user.errors.empty?
          sign_in_and_return_token(user)
        else
          message = 'Invalid reset password token.'
          context.add_error(GraphQL::ExecutionError.new(message))
        end
      end
    end
  end
end
