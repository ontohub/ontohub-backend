class TreePolicy < ApplicationPolicy
  attr_reader :current_user, :repository

  def initialize(current_user, repository)
    @current_user = current_user
    @repository = repository
    super
  end

  def create?
    return false unless current_user
    %w(write admin).include?(RepositoryMembership.find(member_id: current_user.id, repository_id: repository.id)&.role) || %w(write admin).include?(OrganizationMembership.find(member_id: current_user.id, organization_id: repository.owner.id)&.role)
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
end
