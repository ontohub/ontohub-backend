# frozen_string_literal: true

# Policies for PasswordsController
class PasswordPolicy < ApplicationPolicy
  def recover_password?
    true
  end

  def resend_password_recovery_email?
    true
  end
end
