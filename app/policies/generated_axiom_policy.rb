# frozen_string_literal: true

# Policies for the GeneratedAxiom
class GeneratedAxiomPolicy < ApplicationPolicy
  def show?
    RepositoryPolicy.new(current_user, resource&.repository).show?
  end
end
