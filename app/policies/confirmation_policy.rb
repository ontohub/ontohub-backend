# frozen_string_literal: true

# Policies for ConfirmationController
class ConfirmationPolicy < ApplicationPolicy
  def initialize(_current_user = nil, _resource = nil)
    super
  end

  # resend
  def create?
    true
  end

  # confirm
  def update?
    true
  end
end
