# frozen_string_literal: true

# Policies for SessionsController
class SessionPolicy < ApplicationPolicy
  def create?
    !signed_in?
  end
end
