# frozen_string_literal: true

Types::Git::Commit::ActionEnum = GraphQL::EnumType.define do
  name 'CommitAction'
  description 'Possible actions for a commit'

  value 'create'
  value 'rename'
  value 'update'
  value 'rename_and_update'
  value 'remove'
  value 'mkdir'
end
