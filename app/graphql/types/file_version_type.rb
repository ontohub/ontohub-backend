# frozen_string_literal: true

Types::FileVersionType = GraphQL::ObjectType.define do
  name 'FileVersion'
  description 'A versioned file'

  field :repository, !Types::RepositoryType do
    description 'The repository to which this FileVersion belongs'
  end

  field :path, !types.String do
    description 'The path of this file'
  end

  field :commit, !Types::Git::CommitType do
    description 'The Commit that introduced this FileVersion'
    resolve(lambda do |file_version, _arguments, _context|
      git = RepositoryCompound.wrap(file_version.repository).git
      git.commit(file_version.commit_sha)
    end)
  end

  field :action, !Types::ActionType do
    description 'Information about the (to be) performed action'
  end
end
