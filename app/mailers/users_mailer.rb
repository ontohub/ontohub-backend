# frozen_string_literal: true

# Custom mailer class for devise emails
class UsersMailer < Devise::Mailer
  # Adds, for instance, `confirmation_url`
  include Devise::Controllers::UrlHelpers

  def initialize_from_record(record)
    user = User.find(id: JSON.parse(record)['id'])
    @scope_name = :user
    @resource = instance_variable_set("@#{devise_mapping.name}", user)
  end

  # Make sure that this mailer uses the devise views
  default template_path: 'devise/mailer'
end
