# frozen_string_literal: true

# Policies for AccountController
class AccountPolicy < ApplicationPolicy
  def create?
    !signed_in?
  end

  def update?
    user?
  end

  def destroy?
    user?
  end
end
