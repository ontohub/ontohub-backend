# frozen_string_literal: true

Types::Git::CommitType = GraphQL::ObjectType.define do
  name 'Commit'
  description 'A commit of a repository'

  field :id, !types.ID do
    description 'The sha hash of the commit'
  end

  field :parentIds, !types[!types.ID] do
    description 'The parents of the commit'
    property :parent_ids
  end

  field :message, !types.String do
    description 'The commit message'
  end

  field :author, !Types::Git::UserType do
    description 'The author of the commit'

    resolve(lambda do |commit, _arguments, _context|
      GitUser.new(commit.author_name, commit.author_email)
    end)
  end

  field :authoredAt, !Types::TimeType do
    description 'The time the commit was authored at'
    property :authored_date
  end

  field :committer, !Types::Git::UserType do
    description 'The committer of the commit'

    resolve(lambda do |commit, _arguments, _context|
      GitUser.new(commit.committer_name, commit.committer_email)
    end)
  end

  field :committedAt, !Types::TimeType do
    description 'The time the commit was created'
    property :committed_date
  end

  field :referenceNames, !types[!types.String] do
    description 'The names of the references that point to this commit'
    property :ref_names
  end

  field :references, !types[!Types::Git::ReferenceType] do
    description 'The references that point to this commit'
    property :references
  end

  field :directory, types[!Types::Git::DirectoryEntryType] do
    description 'The entries of a directory'
    argument :path, !types.ID do
      description 'The path to the directory to list'
    end
    resolve(lambda do |commit, arguments, _context|
      bringit_wrapper = Bringit::Wrapper.new(commit.repository.path)
      index =
        bringit_wrapper.tree(commit.id, arguments['path']).map do |bringit_tree|
          if bringit_tree.type == :tree
            GitDirectory.new(commit, bringit_tree.path, bringit_tree.name)
          else
            GitFile.new(commit, bringit_tree.path, name: bringit_tree.name)
          end
        end
      index.sort! do |a, b|
        comparison = a.kind <=> b.kind
        comparison.zero? ? (a.name <=> b.name) : comparison
      end

      index unless index.empty?
    end)
  end

  field :file, Types::Git::FileType do
    description 'A file'

    argument :loadAllData, types.Boolean do
      description <<~DESCRIPTION
        Load more than the #{Bringit::Blob::MAX_DATA_DISPLAY_SIZE / 1024 / 1024} Megabytes for the web view
      DESCRIPTION
      default_value false
    end

    argument :path, !types.ID do
      description 'The path to the file'
    end

    resolve(lambda do |commit, arguments, _context|
      git_file = GitFile.new(commit,
                             arguments['path'],
                             load_all_data: arguments['loadAllData'])
      git_file if git_file.exist?
    end)
  end

  field :lsFiles, !types[!types.String] do
    description 'A list of all file paths in the repository'

    resolve(lambda do |commit, _arguments, _context|
      bringit_wrapper = Bringit::Wrapper.new(commit.repository.path)
      bringit_wrapper.ls_files(commit.id)
    end)
  end

  field :diff, !types[!Types::Git::DiffType] do
    description 'The changes that this commit introduced'

    resolve(lambda do |commit, _arguments, _context|
      diffs = []
      commit.diffs.each { |diff| diffs << diff }
      diffs
    end)
  end

  field :fileVersion, Types::FileVersionType do
    description 'A FileVersion for the given path'

    argument :path, !types.ID do
      description 'The path of the FileVersion'
    end

    resolve(lambda do |commit, arguments, _context|
      repository_slug =
        commit.repository.path.match(%r{\/([^\/]+\/[^\/]+)\.git\z})[1]
      FileVersion.first(repository: Repository.first(slug: repository_slug),
                        commit_sha: commit.id,
                        path: arguments['path'])
    end)
  end

  field :document, Types::DocumentType do
    description 'A document containing OMS data'

    argument :locId, !types.ID do
      description 'The Loc/Id of the document'
    end

    resolve(lambda do |commit, arguments, _context|
      Document.where_commit_sha(commit_sha: commit.id,
                                loc_id: arguments['locId']).first
    end)
  end
end
