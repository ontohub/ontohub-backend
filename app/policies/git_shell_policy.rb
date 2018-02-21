# frozen_string_literal: true

# Policies for the GitShell
class GitShellPolicy < ApplicationPolicy
  def authorize?
    git_shell_api_key?
  end
end
