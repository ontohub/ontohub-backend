# frozen_string_literal: true

# Policies for OrganizationsController
class OrganizationPolicy < ApplicationPolicy
  attr_reader :current_user, :organization

  def initialize(current_user, organization)
    @current_user = current_user
    @organization = organization
    super
  end

  def show?
    true
  end

  def update?
    return false unless current_user && organization
    !!OrganizationMembership.
      find(member: current_user, organization: organization, role: 'admin')
  end

  def destroy?
    return false unless current_user && organization
    !!OrganizationMembership.
      find(member: current_user, organization: organization, role: 'admin')
  end
end
