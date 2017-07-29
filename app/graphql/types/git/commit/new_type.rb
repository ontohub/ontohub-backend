# frozen_string_literal: true

Types::Git::Commit::NewType = GraphQL::InputObjectType.define do
  name 'NewCommit'
  description 'Data for committing'

  argument :branch, !types.ID do
    description 'The name of a branch to commit to'
  end

  argument :lastKnownHeadId, types.ID do
    description <<~DESCRIPTION
      The last known id (sha hash) of the HEAD of the branch. This is used to check whether or not the branch has changed in the meantime.
    DESCRIPTION
  end

  argument :message, !types.String do
    description 'A brief description of the changes in this commit'
  end

  argument :files, !types[!Types::Git::File::ChangesetType] do
    description 'The changes to commit to the repository'
  end
end
