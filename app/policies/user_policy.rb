# frozen_string_literal: true

# Policies for UsersController
class UserPolicy < ApplicationPolicy
  def show?
    true
  end

  def show_current_user?
    !!current_user
  end

  def access_private_data?
    !!current_user && current_user.id == resource.id
  end
end
