# frozen_string_literal: true

# Policies for PasswordsController
class PasswordPolicy < ApplicationPolicy
  def recover_password?
    not_an_api_key?
  end

  def resend_password_recovery_email?
    not_an_api_key?
  end
end
