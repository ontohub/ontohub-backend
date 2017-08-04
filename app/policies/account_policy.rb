# frozen_string_literal: true

# Policies for AccountController
class AccountPolicy < ApplicationPolicy
  def create?
    !current_user
  end

  def update?
    !!current_user
  end

  def destroy?
    !!current_user
  end
end
