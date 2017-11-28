# frozen_string_literal: true

# Policies for the SignatureMorphism
class SignatureMorphismPolicy < ApplicationPolicy
  def show?
    !!resource&.repositories&.any? do |repository|
      RepositoryPolicy.new(current_user, repository).show?
    end
  end
end
