# frozen_string_literal: true

require 'ostruct'

module Mutations
  # GraphQL mutation to resend a confirmation email to a user
  class ResendPasswordResetEmailMutation < AbstractDeviseMutation
    # Note, that this does not directly use Devise controller actions to
    # perform the mutation.  Devise's corresponding controller action,
    # which would normally be called, performs various things we don't need for
    # an API only application (including setting flash messages, rendering the
    # response, bypassing the signin). This code mirrors what is left of the
    # that action after stripping the rest away.
    # Make sure that this code is updated if Devise adds relevant code to the
    # controller action.
    #
    # For reference, see the
    # V2::Users::PasswordController#resend_password_recovery_email and
    # https://github.com/plataformatec/devise/blob/7a44233fb9439e7cc4d1503b14f02a1d9f6da7b9/app/controllers/devise/passwords_controller.rb#L12-L21
    def call(_root, arguments, context)
      setup_devise(context)
      User.send_reset_password_instructions(email: arguments['email'])
      true
    end
  end
end
