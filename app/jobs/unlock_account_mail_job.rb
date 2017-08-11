# frozen_string_literal: true

# Send a mail with an account unlock link
class UnlockAccountMailJob < ApplicationJob
  queue_as :mail

  def perform(*args)
    # Do something later
  end
end
