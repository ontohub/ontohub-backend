# frozen_string_literal: true

require 'ostruct'

module Mutations
  module Account
    ResendUnlockAccountEmailMutation = GraphQL::Field.define do
      type !types.Boolean
      description 'Resends the unlock account email to a user'

      argument :email, !types.String do
        description 'The email address of the user'
      end

      authorize! :resend_unlocking_email, policy: :unlock

      resolve ResendUnlockAccountEmailResolver.new
    end

    # GraphQL mutation to resend a confirmation email to a user
    class ResendUnlockAccountEmailResolver < AbstractDeviseResolver
      # Note, that this does not directly use Devise controller actions to
      # perform the mutation. Devise's corresponding controller action, which
      # would normally be called, performs various things we don't need for an
      # API only application (including setting flash messages, rendering the
      # response, bypassing the signin). This code mirrors what is left of the
      # that action after stripping the rest away. Make sure that this code is
      # updated if Devise adds relevant code to the controller action.
      #
      # For reference, see
      # https://github.com/plataformatec/devise/blob/7a44233fb9439e7cc4d1503b14f02a1d9f6da7b9/app/controllers/devise/unlocks_controller.rb#L10-L19
      def call(_root, arguments, context)
        setup_devise(context)
        User.send_unlock_instructions(email: arguments['email'])
        true
      end
    end
  end
end
