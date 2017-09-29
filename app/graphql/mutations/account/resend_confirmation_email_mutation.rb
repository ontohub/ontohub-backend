# frozen_string_literal: true

require 'ostruct'

module Mutations
  module Account
    ResendConfirmationEmailMutation = GraphQL::Field.define do
      type !types.Boolean
      description 'Resends the confirmation email to a user'

      argument :email, !types.String do
        description 'The email address of the user'
      end

      authorize! :create, :confirmation

      resolve ResendConfirmationEmailResolver.new
    end

    # GraphQL mutation to resend a confirmation email to a user
    class ResendConfirmationEmailResolver < AbstractDeviseResolver
      # Note, that this does not directly use Devise controller actions to
      # perform the mutation. Devise's corresponding controller action, which
      # would normally be called, performs various things we don't need for an
      # API only application (including setting flash messages, rendering the
      # response, bypassing the signin). This code mirrors what is left of the
      # that action after stripping the rest away. Make sure that this code is
      # updated if Devise adds relevant code to the controller action.
      #
      # For reference, see the
      # V2::Users::ConfirmationController#resend_confirmation_email and
      # https://github.com/plataformatec/devise/blob/7a44233fb9439e7cc4d1503b14f02a1d9f6da7b9/app/controllers/devise/confirmations_controller.rb#L8-L17
      def call(_root, arguments, context)
        setup_devise(context)
        User.send_confirmation_instructions(email: arguments['email'])
        true
      end
    end
  end
end
