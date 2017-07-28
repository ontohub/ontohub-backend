# frozen_string_literal: true

# Policies for SessionsController
class SessionPolicy < ApplicationPolicy
  def create?
    !current_user
  end
end
