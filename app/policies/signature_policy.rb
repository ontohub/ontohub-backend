# frozen_string_literal: true

# Policies for the Signature
class SignaturePolicy < ApplicationPolicy
  def show?
    !!resource&.repositories&.any? do |repository|
      RepositoryPolicy.new(current_user, repository).show?
    end
  end
end
