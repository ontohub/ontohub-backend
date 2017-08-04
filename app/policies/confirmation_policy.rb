# frozen_string_literal: true

# Policies for ConfirmationController
class ConfirmationPolicy < ApplicationPolicy
  # resend
  def create?
    true
  end

  # confirm
  def update?
    true
  end
end
