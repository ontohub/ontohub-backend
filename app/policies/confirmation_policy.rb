# frozen_string_literal: true

# Policies for ConfirmationController
class ConfirmationPolicy < ApplicationPolicy
  # resend
  def create?
    not_an_api_key?
  end

  # confirm
  def update?
    not_an_api_key?
  end
end
