# frozen_string_literal: true

# Policies for RepositoriesController
class RepositoryPolicy < ApplicationPolicy
  def show?
    resource.public_access ||
      !!current_user&.accessible_repositories&.map(&:to_param)&.
        include?(resource.to_param)
  end

  def create?(owner)
    return false unless current_user
    if owner.is_a?(User)
      owner.id == current_user.id
    elsif owner.is_a?(Organization)
      !!OrganizationMembership.
        find(member: current_user, organization: owner, role: 'admin')
    else
      false
    end
  end

  def update?
    return false unless current_user
    create?(resource.owner) || !!RepositoryMembership.
      find(member: current_user, repository: resource,
           role: 'admin')
  end

  def index?
    true
  end

  def destroy?
    update?
  end
end
