# frozen_string_literal: true

# Policies for TreesController
class TreePolicy < ApplicationPolicy
  def create?
    return false unless current_user
    repository_write? || organization_write?
  end

  def show?
    RepositoryPolicy.new(current_user, resource.repository).show?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def multi_action?
    create?
  end

  protected

  def repository_write?
    %w(write admin).include?(RepositoryMembership.
      find(member_id: current_user.id,
           repository_id: resource.repository.id)&.role)
  end

  def organization_write?
    %w(write admin).include?(OrganizationMembership.
      find(member_id: current_user.id,
           organization_id: resource.repository.owner.id)&.role)
  end
end
