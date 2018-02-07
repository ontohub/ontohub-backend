# frozen_string_literal: true

module Mutations
  module Account
    SaveAccountMutation = GraphQL::Field.define do
      type Types::UserType
      description 'Updates the current user account'

      argument :data, !Types::User::ChangesetType do
        description 'Updated fields of the user'
      end

      argument :password, !types.String do
        description 'Password of the current user to confirm the update'
      end

      resource ->(_root, _arguments, context) { context[:current_user] },
               pass_through: true

      authorize! :update, policy: :account

      resolve SaveAccountResolver.new
    end

    # GraphQL mutation to update the current user account
    class SaveAccountResolver
      # Note, that this does not directly use Devise controller actions to
      # perform the mutation. Devise's corresponding controller action, which
      # would normally be called, performs various things we don't need for an
      # API only application (including setting flash messages, rendering the
      # response, bypassing the signin). This code mirrors what is left of the
      # that action after stripping the rest away. Make sure that this code is
      # updated if Devise adds relevant code to the controller action.
      #
      # For reference, see
      # https://github.com/plataformatec/devise/blob/7a44233fb9439e7cc4d1503b14f02a1d9f6da7b9/app/controllers/devise/registrations_controller.rb#L44-L63
      def call(user, arguments, _context)
        params = arguments[:data].to_h.compact
        user.update(params) if user.valid_password?(arguments[:password])
        IndexingJob.
          perform_later('class' => 'User', 'id' => user.id)
        user
      end
    end
  end
end
