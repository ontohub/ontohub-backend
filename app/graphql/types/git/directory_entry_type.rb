# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Types::Git::DirectoryEntryType = GraphQL::InterfaceType.define do
  # rubocop:enable Metrics/BlockLength
  name 'DirectoryEntry'
  description 'A directory entry (directory or file) of a repository'

  field :name, !types.String do
    description 'The name of the entry'
  end

  field :path, !types.String do
    description 'The path of the entry'
  end

  # rubocop:disable Metrics/BlockLength
  field :log, !types[!Types::Git::CommitType] do
    # rubocop:enable Metrics/BlockLength
    description <<~DESCRIPTION
      The history (git log) of this entry starting with the most recent changes
    DESCRIPTION

    argument :limit, types.Int do
      description 'Maximum number of commits to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n commits'
      default_value 0
    end

    argument :skipMerges, types.Boolean do
      description 'Whether or not to skip merge commits in the history'
      default_value false
    end

    argument :before, Types::TimeType do
      description 'Only show commits from before this date/time'
    end

    argument :after, Types::TimeType do
      description 'Only show commits from after this date/time'
    end

    resolve(lambda do |base, arguments, _context|
      is_array = base.is_a?(Array) # Is the base object a directory listing?
      base = base.first if is_array
      path = is_array ? File.dirname(base.path) : base.path
      commit = base.commit
      gitlab_wrapper = base.gitlab

      gitlab_wrapper.log(ref: commit.id,
                         path: path,
                         limit: arguments['limit'],
                         offset: arguments['skip'],
                         skip_merges: arguments['skipMerges'],
                         before: arguments['before'],
                         after: arguments['after'])
    end)
  end
end
