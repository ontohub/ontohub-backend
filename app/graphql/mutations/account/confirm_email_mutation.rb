# frozen_string_literal: true

module Mutations
  module Account
    ConfirmEmailMutation = GraphQL::Field.define do
      type Types::User::SessionTokenType
      description 'Confirms the email address of a user'

      argument :token, !types.String do
        description 'The confirmation token from the confirmation email'
      end

      authorize! :update, policy: :confirmation

      resolve ConfirmEmailResolver.new
    end

    # GraphQL mutation to confirm a user's email address
    class ConfirmEmailResolver < AbstractDeviseResolver
      # Note, that this does not directly use Devise controller actions to
      # perform the mutation. Devise's corresponding controller action, which
      # would normally be called, performs various things we don't need for an
      # API only application (including setting flash messages, rendering the
      # response, bypassing the signin). This code mirrors what is left of the
      # that action after stripping the rest away. Make sure that this code is
      # updated if Devise adds relevant code to the controller action.
      #
      # For reference, see the
      # V2::Users::ConfirmationController#confirm_email_address and
      # https://github.com/plataformatec/devise/blob/7a44233fb9439e7cc4d1503b14f02a1d9f6da7b9/app/controllers/devise/confirmations_controller.rb#L20-L30
      def call(_root, arguments, context)
        setup_devise(context)
        user = ::User.confirm_by_token(arguments['token'])
        if user.errors.empty?
          sign_in_and_return_token(user)
        else
          message = 'Invalid confirmation token.'
          context.add_error(GraphQL::ExecutionError.new(message))
        end
      end
    end
  end
end
