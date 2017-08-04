# frozen_string_literal: true

# Policies for UnlockController
class UnlockPolicy < ApplicationPolicy
  def resend_unlocking_email?
    true
  end

  def unlock_account?
    true
  end
end
