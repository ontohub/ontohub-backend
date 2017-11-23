# frozen_string_literal: true

# Policies for the ReasonerConfiguration
class ReasonerConfigurationPolicy < ApplicationPolicy
  def show?
    !!resource&.repositories&.any? do |repository|
      RepositoryPolicy.new(current_user, repository).show?
    end
  end
end
