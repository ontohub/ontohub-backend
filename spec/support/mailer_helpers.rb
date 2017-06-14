# frozen_string_literal: true

module MailerHelpers
  def emails
    ActionMailer::Base.deliveries
  end

  def last_email
    emails.last
  end
end

RSpec.configure do |config|
  config.include MailerHelpers, type: :mailer
end
