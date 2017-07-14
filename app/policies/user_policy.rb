class UserPolicy < ApplicationPolicy
  attr_reader :current_user, :user

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
    super
  end

  def show?
    true
  end

  def show_current_user?
    !!@current_user
  end
end