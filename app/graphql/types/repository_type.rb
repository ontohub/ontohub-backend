# frozen_string_literal: true

Types::RepositoryType = GraphQL::ObjectType.define do
  name 'Repository'
  description 'Data of a repository'

  field :id, !types.ID do
    description 'ID of the repository'
    property :to_param
  end

  field :name, !types.String do
    description 'Name of the repository'
  end

  field :description, types.String do
    description 'Description of the repository'
  end

  field :owner, !Types::OrganizationalUnitType do
    description 'Owner of the repository'
  end

  field :contentType, !Types::Repository::ContentTypeEnum do
    description 'Type of the repository'
    property :content_type
  end

  field :visibility, !Types::Repository::VisibilityEnum do
    description 'Visibility of the repository'
    resolve(lambda do |repository, _arguments, _context|
      repository.public_access ? 'public' : 'private'
    end)
  end

  field :permissions, Types::Repository::PermissionsType do
    description "The current_user's permissions for this repository"

    resolve(lambda do |repository, _arguments, context|
      return unless context[:current_user]
      repository
    end)
  end

  field :memberships, !types[!Types::Repository::MembershipType] do
    description "List of the repository's memberships"

    argument :limit, types.Int do
      description 'Maximum number of memberships to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n memberships'
      default_value 0
    end

    argument :role, Types::Repository::RoleEnum do
      description 'Filter the users by the membership role'
    end

    resolve(lambda do |repository, arguments, _context|
      dataset = RepositoryMembership.where(repository_id: repository.id)
      dataset = dataset.where(role: arguments['role']) if arguments['role']
      dataset.join(:organizational_units, id: :member_id).
        order(Sequel[:organizational_units][:slug]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :urlMappings, !types[!Types::Repository::UrlMappingType] do
    description 'List of all URL Mappings of this repository'
    property :url_mappings
  end

  field :defaultBranch, types.String do
    description 'Default branch of the repository'
    property :default_branch
    resolve(lambda do |repository, _arguments, _context|
      repository.git.default_branch
    end)
  end

  field :branches, !types[!types.String] do
    description 'Branches of the repository'
    resolve(lambda do |repository, _arguments, _context|
      repository.git.branch_names
    end)
  end

  field :branch, Types::Git::BranchType do
    description 'Details of a branch'

    argument :name, !types.String do
      description 'The name of the branch'
    end

    resolve(lambda do |repository, arguments, _context|
      repository.git.find_branch(arguments['name'])
    end)
  end

  field :tags, !types[!types.String] do
    description 'Tags of the repository'
    resolve(lambda do |repository, _arguments, _context|
      repository.git.tag_names
    end)
  end

  field :tag, Types::Git::TagType do
    description 'Details of a tag'

    argument :name, !types.String do
      description 'The name of the tag'
    end

    resolve(lambda do |repository, arguments, _context|
      repository.git.find_tag(arguments['name'])
    end)
  end

  field :commit, Types::Git::CommitType do
    description 'Find a commit by revision'

    argument :revision, types.ID do
      description <<~DESCRIPTION
        The revision to query for (default: What is retruned in the defaultBranch field)
      DESCRIPTION
    end

    resolve(lambda do |repository, arguments, _context|
      revision = arguments['revision'] || repository.git.default_branch
      repository.git.commit(revision)
    end)
  end

  field :diff, !types[!Types::Git::DiffType] do
    description 'The changes between two commits'

    argument :from, !types.String do
      description 'The base commit for the diff'
    end

    argument :to, !types.String do
      description 'The target commit for the diff'
    end

    argument :paths, types[!types.String] do
      description 'An optional list of paths to restrict the diff to'
    end

    resolve(lambda do |repository, arguments, _context|
      begin
        paths = Array(arguments['paths'])
        diffs = []
        repository.git.
          diff(arguments['from'], arguments['to'], {}, *paths).each do |diff|
            diffs << diff
          end
        diffs
      rescue Rugged::ReferenceError => e
        argument = nil
        revspec = e.message.match(/revspec '(\S+)' not found/i)[1]
        %w(from to).each { |arg| argument = arg if arguments[arg] == revspec }
        GraphQL::ExecutionError.new(%("#{argument}" #{e.message}))
      end
    end)
  end

  field :log, !types[!Types::Git::CommitType] do
    description <<~DESCRIPTION
      The history (git log) of the repository starting with the most recent changes
    DESCRIPTION

    argument :revision, types.String do
      description 'The newest revision to show in the history'
    end

    argument :path, types.String do
      description 'A path to a file or directory to see the history of'
      default_value '/'
    end

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

    resolve(lambda do |repository, arguments, _context|
      revision = arguments['revision'] || repository.git.default_branch
      repository.git.log(ref: revision,
                         path: arguments['path'],
                         limit: arguments['limit'],
                         offset: arguments['skip'],
                         skip_merges: arguments['skipMerges'],
                         before: arguments['before'],
                         after: arguments['after'])
    end)
  end
end
