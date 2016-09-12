# frozen_string_literal: true

# The basic mailer - This is a default class of Rails
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
