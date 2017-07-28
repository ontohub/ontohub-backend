# frozen_string_literal: true

# Policies for TreesController
class TreePolicy < ApplicationPolicy
  attr_reader :current_user, :repository

  def initialize(current_user, repository)
    @current_user = current_user
    @repository = repository
    super
  end

  def create?
    return false unless current_user
    repository_write? || organization_write?
  end

  def show?
    RepositoryPolicy.new(current_user, repository).show?
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
      find(member_id: current_user.id, repository_id: repository.id)&.role)
  end

  def organization_write?
    %w(write admin).include?(OrganizationMembership.
      find(member_id: current_user.id,
           organization_id: repository.owner.id)&.role)
  end
end
