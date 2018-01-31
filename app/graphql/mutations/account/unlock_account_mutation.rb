# frozen_string_literal: true

require 'ostruct'

module Mutations
  module Account
    UnlockAccountMutation = GraphQL::Field.define do
      type Types::User::SessionTokenType
      description 'Unlocks a locked user account'

      argument :token, !types.String do
        description 'The unlock account token from the unlock account email'
      end

      authorize! :unlock_account, policy: :unlock

      resolve UnlockAccountResolver.new
    end

    # GraphQL mutation to confirm a user's email address
    class UnlockAccountResolver < AbstractDeviseResolver
      # Note, that this does not directly use Devise controller actions to
      # perform the mutation. Devise's corresponding controller action, which
      # would normally be called, performs various things we don't need for an
      # API only application (including setting flash messages, rendering the
      # response, bypassing the signin). This code mirrors what is left of the
      # that action after stripping the rest away. Make sure that this code is
      # updated if Devise adds relevant code to the controller action.
      #
      # For reference, see
      # https://github.com/plataformatec/devise/blob/7a44233fb9439e7cc4d1503b14f02a1d9f6da7b9/app/controllers/devise/unlocks_controller.rb#L22-L32
      def call(_root, arguments, context)
        setup_devise(context)
        user = User.unlock_access_by_token(arguments['token'])
        if user.errors.empty?
          sign_in_and_return_token(user)
        else
          message = 'Invalid unlock token.'
          context.add_error(GraphQL::ExecutionError.new(message))
        end
      end
    end
  end
end
