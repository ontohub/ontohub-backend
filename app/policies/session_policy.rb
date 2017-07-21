# frozen_string_literal: true

# Policies for SessionsController
class SessionPolicy < ApplicationPolicy
  attr_reader :current_user

  def initialize(current_user, _args = nil)
    @current_user = current_user
    super
  end

  def create?
    !current_user
  end
end
