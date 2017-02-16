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
    def commit_file(options, previous_head_sha = nil)
      insert_defaults(options)

      branch = options[:commit][:branch]
      path = options[:file][:path]
      options[:file][:update] =
        branch_exists?(branch) && path_exists?(branch, path)

      commit_change(options, :add_or_update, previous_head_sha)
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
      commit_change(options, :remove, previous_head_sha)
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
      commit_change(options, :rename, previous_head_sha)
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
      insert_defaults(options)
      prevent_overwriting_tree(path, options) unless empty?
      options[:file] = {path: File.join(path, '.gitkeep'), content: ''}
      commit_file(options, previous_head_sha)
    end

    protected

    # TODO: This needs to be mutexed accross all backend processes/threads and
    # Git-SSH.
    def commit_change(options, action, previous_head_sha)
      insert_defaults(options)
      prevent_overwriting_previous_changes(options, previous_head_sha)
      Gitlab::Git::Blob.commit(gitlab, options, action)
    end

    # TODO: Instead of comparing the HEAD with the previous commit_sha, actually
    # try merging and only raise if there is a conflict. Add the merge conflict
    # to the Error
    def prevent_overwriting_previous_changes(options, previous_head_sha)
      return unless conflict?(options, previous_head_sha)
      raise HeadChangedError.new('The branch has changed since editing.',
                                 options)
    end

    # rubocop:disable Style/GuardClause
    def prevent_overwriting_tree(path, options)
      unless blob(options[:commit][:branch], path).nil?
        raise InvalidPathError, 'Path already exists as a file.'
      end
      if tree(options[:commit][:branch], path).any?
        raise InvalidPathError, 'Path already exists as a directory.'
      end
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
  end
end
