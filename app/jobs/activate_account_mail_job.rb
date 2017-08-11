# frozen_string_literal: true

# Send a mail with an account activation link
class ActivateAccountMailJob < ApplicationJob
  queue_as :mail

  def perform(*args)
    # Do something later
  end
end
