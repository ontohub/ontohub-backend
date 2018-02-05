# frozen_string_literal: true

# Policies for Document
class DocumentPolicy < ApplicationPolicy
  # Scopes a document dataset to accessible document of the current user
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope if hets_api_key?
      return scope.where(false) if git_shell_api_key?
      return scope if admin?
      return public_scope unless user?
      private_scope
    end

    protected

    def joint_scope
      scope.
        graph(:file_versions,
              {Sequel[:document_policy_scope_file_versions][:id] =>
                 Sequel[:loc_id_bases][:file_version_id]},
              table_alias: :document_policy_scope_file_versions, select: false).
        graph(:repositories,
              {Sequel[:document_policy_scope_repositories][:id] =>
                 Sequel[:document_policy_scope_file_versions][:repository_id]},
              table_alias: :document_policy_scope_repositories, select: false)
    end

    def public_scope
      joint_scope.
        where(Sequel[:document_policy_scope_repositories][:public_access] =>
                true)
    end

    def private_scope
      joint_scope.
        where(Sequel[:document_policy_scope_repositories][:id] =>
                current_user.accessible_repositories_dataset.
                  select(Sequel[:repositories][:id])).
        or(Sequel[:document_policy_scope_repositories][:public_access] => true)
    end
  end
end
