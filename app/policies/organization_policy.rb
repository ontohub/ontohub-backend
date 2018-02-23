# frozen_string_literal: true

# Policies for OrganizationsController
class OrganizationPolicy < ApplicationPolicy
  def create?
    user?
  end

  def show?
    not_an_api_key?
  end

  def update?
    return false unless resource
    user? && !!OrganizationMembership.
      find(member: current_user, organization: resource, role: 'admin')
  end

  def destroy?
    update?
  end
end
