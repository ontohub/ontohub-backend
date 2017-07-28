# frozen_string_literal: true

# Policies for UsersController
class UserPolicy < ApplicationPolicy
  def show?
    true
  end

  def show_current_user?
    !!current_user
  end
end
