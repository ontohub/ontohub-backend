# frozen_string_literal: true

# Policies for RepositoriesController
# No need for policies for Tree, Diff, Commit; just use this policy
class RepositoryPolicy < ApplicationPolicy
  # Scopes a repository dataset to accessible repositories of the current user
  class Scope < ApplicationPolicy::Scope
    # rubocop:disable Metrics/AbcSize
    def resolve
      # rubocop:enable Metrics/AbcSize
      return scope if hets_api_key?
      return scope.where(false) if git_shell_api_key?
      return scope if admin?
      return scope.where(public_access: true) unless user?

      scope.intersect(current_user.accessible_repositories_dataset.
                        or(public_access: true))
    end
  end

  def show?
    return false unless resource
    return false if git_shell_api_key?
    return true if hets_api_key?
    resource.public_access ||
      !!current_user&.accessible_repositories_dataset&.
        where(slug: resource.to_param)&.any?
  end

  def create?(owner)
    return false unless user?
    if owner.is_a?(User)
      owner.id == current_user.id
    elsif owner.is_a?(Organization)
      !!OrganizationMembership.
        find(member_id: current_user&.id, organization_id: owner&.id,
             role: 'admin')
    else
      false
    end
  end

  def update?
    return false unless user?
    create?(resource.owner) || !!RepositoryMembership.
      find(member_id: current_user&.id, repository_id: resource&.id,
           role: 'admin')
  end

  def index?
    true
  end

  def destroy?
    update?
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def write?
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    return false if resource.nil?
    owner = resource.owner
    return false if resource.remote_type == 'mirror'
    return false unless user?
    return true if owner.id == current_user.id

    if owner.is_a?(Organization)
      !!OrganizationMembership.
        find(member_id: current_user.id,
             organization: owner,
             role: %w(write admin))
    else
      # Owner can only be an Organization or a User
      !!RepositoryMembership.
        find(member_id: current_user.id,
             repository_id: resource.id,
             role: %w(write admin))
    end
  end
end
