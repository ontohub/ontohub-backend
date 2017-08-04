# frozen_string_literal: true

# Policies for VersionsController
class VersionPolicy < ApplicationPolicy
  def show?
    true
  end
end
