# frozen_string_literal: true

# Policies for the ReasonerConfiguration
class ReasoningAttemptPolicy < ApplicationPolicy
  def show?
    RepositoryPolicy.new(current_user, resource&.repository).show?
  end
end
