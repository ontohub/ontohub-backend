# frozen_string_literal: true

# Send a mail with a password rest link
class ResetPasswordMailJob < ApplicationJob
  queue_as :mail

  def perform(*args)
    # Do something later
  end
end
