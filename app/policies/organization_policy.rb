# frozen_string_literal: true

# Policies for OrganizationsController
class OrganizationPolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    return false unless current_user && resource
    !!OrganizationMembership.
      find(member: current_user, organization: resource, role: 'admin')
  end

  def destroy?
    update?
  end
end
