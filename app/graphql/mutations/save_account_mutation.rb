# frozen_string_literal: true

module Mutations
  # GraphQL mutation to update the current user account
  class SaveAccountMutation
    # Note, that this does not use Devise to update the user account. At the
    # time of writing, Devise's update action on the RegistrationsController,
    # which would normally be called, performs various things we don't need for
    # an API only application (including setting flash messages, rendering the
    # response, bypassing the signin). This code mirrors what is left of the
    # devise `update` action after stripping the rest away.
    # Make sure that this code is updated if Devise adds relevant code to the
    # controller action.
    #
    # For reference: https://github.com/plataformatec/devise/blob/7a44233fb9439e7cc4d1503b14f02a1d9f6da7b9/app/controllers/devise/registrations_controller.rb#L44-L63

    def call(user, arguments, _context)
      params = arguments[:data].to_h.compact
      user.update(params) if user.valid_password?(arguments[:password])
      user
    end
  end
end
