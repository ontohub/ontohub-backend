# frozen_string_literal: true

# Policies for the GitShell
class GitShellPolicy < ApplicationPolicy
  def authorize?
    current_user.is_a?(GitShellApiKey)
  end
end
