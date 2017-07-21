# frozen_string_literal: true

# Policies for UsersController
class UserPolicy < ApplicationPolicy
  attr_reader :current_user, :user

  def initialize(current_user, _user = nil)
    @current_user = current_user
    super
  end

  def show?
    true
  end

  def show_current_user?
    !!@current_user
  end
end
