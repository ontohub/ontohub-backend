class AccountPolicy < ApplicationPolicy
  attr_reader :current_user

  def initialize(current_user, _args = nil)
    @current_user = current_user
    super
  end

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
