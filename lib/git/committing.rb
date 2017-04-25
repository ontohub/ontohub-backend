# frozen_string_literal: true

class Git
  # Methods for committing
  module Committing
    class Error < StandardError; end
    class InvalidPathError < Error; end

    # This error is thrown when attempting to commit on a branch whose HEAD has
    # changed.
    class HeadChangedError < Error
      attr_reader :options
      def initialize(message, options)
        super(message)
        @options = options
      end
    end

    # Create a file in repository and return commit sha
    #
    # options should contain next structure:
    #   file: {
    #     content: 'Lorem ipsum...',
    #     path: 'documents/story.txt'
    #   },
    #   author: {
    #     email: 'user@example.com',
    #     name: 'Test User',
    #     time: Time.now    # optional - default: Time.now
    #   },
    #   committer: {
    #     email: 'user@example.com',
    #     name: 'Test User',
    #     time: Time.now    # optional - default: Time.now
    #   },
    #   commit: {
    #     message: 'Wow such commit',
    #     branch: 'master',    # optional - default: 'master'
    #     update_ref: false    # optional - default: true
    #   }
    def create_file(options, previous_head_sha = nil)
      commit_with(options, previous_head_sha) do |index_options|
        Gitlab::Git::Index.new(gitlab).create(index_options)
      end
    end

    # Commit (add or update) file in repository and return commit sha
    #
    # options should contain next structure:
    #   file: {
    #     content: 'Lorem ipsum...',
    #     path: 'documents/story.txt'
    #   },
    #   author: {
    #     email: 'user@example.com',
    #     name: 'Test User',
    #     time: Time.now    # optional - default: Time.now
    #   },
    #   committer: {
    #     email: 'user@example.com',
    #     name: 'Test User',
    #     time: Time.now    # optional - default: Time.now
    #   },
    #   commit: {
    #     message: 'Wow such commit',
    #     branch: 'master',    # optional - default: 'master'
    #     update_ref: false    # optional - default: true
    #   }
    def update_file(options, previous_head_sha = nil)
      previous_path = options[:file].delete(:previous_path)
      action = previous_path && previous_path != path ? :move : :update

      commit_with(options, previous_head_sha) do |index_options|
        Gitlab::Git::Index.new(gitlab).send(action, index_options)
      end
    end

    # Remove file from repository and return commit sha
    #
    # options should contain next structure:
    #   file: {
    #     path: 'documents/story.txt'
    #   },
    #   author: {
    #     email: 'user@example.com',
    #     name: 'Test User',
    #     time: Time.now    # optional - default: Time.now
    #   },
    #   committer: {
    #     email: 'user@example.com',
    #     name: 'Test User',
    #     time: Time.now    # optional - default: Time.now
    #   },
    #   commit: {
    #     message: 'Remove FILENAME',
    #     branch: 'master'    # optional - default: 'master'
    #   }
    def remove_file(options, previous_head_sha = nil)
      commit_with(options, previous_head_sha) do |index_options|
        Gitlab::Git::Index.new(gitlab).delete(index_options)
      end
    end

    # Rename file from repository and return commit sha
    #
    # options should contain next structure:
    #   file: {
    #     previous_path: 'documents/old_story.txt'
    #     path: 'documents/story.txt'
    #     content: 'Lorem ipsum...',
    #     update: true/false
    #   },
    #   author: {
    #     email: 'user@example.com',
    #     name: 'Test User',
    #     time: Time.now    # optional - default: Time.now
    #   },
    #   committer: {
    #     email: 'user@example.com',
    #     name: 'Test User',
    #     time: Time.now    # optional - default: Time.now
    #   },
    #   commit: {
    #     message: 'Rename FILENAME',
    #     branch: 'master'    # optional - default: 'master'
    #   }
    #
    def rename_file(options, previous_head_sha = nil)
      commit_with(options, previous_head_sha) do |index_options|
        Gitlab::Git::Index.new(gitlab).move(index_options)
      end
    end

    # Create a new directory with a .gitkeep file. Creates
    # all required nested directories (i.e. mkdir -p behavior)
    #
    # options should contain next structure:
    #   author: {
    #     email: 'user@example.com',
    #     name: 'Test User',
    #     time: Time.now    # optional - default: Time.now
    #   },
    #   committer: {
    #     email: 'user@example.com',
    #     name: 'Test User',
    #     time: Time.now    # optional - default: Time.now
    #   },
    #   commit: {
    #     message: 'Wow such commit',
    #     branch: 'master',    # optional - default: 'master'
    #     update_ref: false    # optional - default: true
    #   }
    def mkdir(path, options, previous_head_sha = nil)
      options[:file][:path] = path
      insert_defaults(options)
      commit_with(options, previous_head_sha) do |index_options|
        Gitlab::Git::Index.new(gitlab).create_dir(index_options)
      end
    end

    protected

    # TODO: Instead of comparing the HEAD with the previous commit_sha, actually
    # try merging and only raise if there is a conflict. Add the merge conflict
    # to the Error.
    # See issue #97.
    def prevent_overwriting_previous_changes(options, previous_head_sha)
      return unless conflict?(options, previous_head_sha)
      raise HeadChangedError.new('The branch has changed since editing.',
                                 options)
    end

    def conflict?(options, previous_head_sha)
      !previous_head_sha.nil? &&
        branch_sha(options[:commit][:branch]) != previous_head_sha
    end

    def insert_defaults(options)
      options[:author][:time] ||= Time.now
      options[:committer][:time] ||= Time.now
      options[:commit][:branch] ||= 'master'
      options[:commit][:update_ref] = true if options[:commit][:update_ref].nil?
      normalize_ref(options)
    end

    def normalize_ref(options)
      return if options[:commit][:branch].start_with?('refs/')
      options[:commit][:branch] = 'refs/heads/' + options[:commit][:branch]
    end

    # TODO: This needs to be mutexed accross all backend processes/threads and
    # Git-SSH.
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    def commit_with(options, previous_head_sha)
      insert_defaults(options)
      prevent_overwriting_previous_changes(options, previous_head_sha)

      commit = options[:commit]
      ref = commit[:branch]
      ref = 'refs/heads/' + ref unless ref.start_with?('refs/')
      update_ref = commit[:update_ref].nil? ? true : commit[:update_ref]

      index = Gitlab::Git::Index.new(gitlab)

      parents = []
      unless empty?
        rugged_ref = rugged.references[ref]
        unless rugged_ref
          raise Gitlab::Git::Repository::InvalidRef, 'Invalid branch name'
        end
        last_commit = rugged_ref.target
        index.read_tree(last_commit.tree)
        parents = [last_commit]
      end

      file = options[:file]
      index_options = {}
      index_options[:file_path] = file[:path] if file[:path]
      index_options[:content] = file[:content] if file[:content]
      index_options[:encoding] = file[:encoding] if file[:encoding]
      if file[:previous_path]
        index_options[:previous_path] = file[:previous_path]
      end
      yield(index_options)

      opts = {}
      opts[:tree] = index.write_tree
      opts[:author] = options[:author]
      opts[:committer] = options[:committer]
      opts[:message] = commit[:message]
      opts[:parents] = parents
      opts[:update_ref] = ref if update_ref

      Rugged::Commit.create(rugged, opts)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength
  end
end
