# frozen_string_literal: true

# Policies for UsersController
class UserPolicy < ApplicationPolicy
  def show?
    not_an_api_key?
  end

  def show_current_user?
    user?
  end

  def access_private_data?
    user? && current_user.id == resource.id
  end
end
