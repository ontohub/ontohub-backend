# frozen_string_literal: true

# Policies for UnlockController
class UnlockPolicy < ApplicationPolicy
  def resend_unlocking_email?
    not_an_api_key?
  end

  def unlock_account?
    not_an_api_key?
  end
end
