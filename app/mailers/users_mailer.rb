# frozen_string_literal: true

# Custom mailer class for devise emails
class UsersMailer < Devise::Mailer
  # Adds, for instance, `confirmation_url`
  include Devise::Controllers::UrlHelpers

  # Make sure that this mailer uses the devise views
  default template_path: 'devise/mailer'
end
