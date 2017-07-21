# frozen_string_literal: true

# Policies for RepositoriesController
class RepositoryPolicy < ApplicationPolicy
  attr_reader :current_user, :repository

  def initialize(current_user, repository)
    @current_user = current_user
    @repository = repository
    super
  end

  def show?
    repository.public_access ||
      !!current_user&.accessible_repositories&.map(&:to_param)&.
        include?(repository.to_param)
  end

  def create?(owner)
    return false unless current_user
    if owner.is_a?(User)
      owner&.id == current_user&.id
    elsif owner.is_a?(Organization)
      !!OrganizationMembership.
        find(member: current_user, organization: owner, role: 'admin')
    else
      false
    end
  end

  def update?
    return false unless current_user
    create?(repository.owner) || !!RepositoryMembership.
      find(member: current_user, repository: repository,
           role: 'admin')
  end

  def index?
    true
  end

  def destroy?
    update?
  end
end
