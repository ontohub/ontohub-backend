# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

# Allows to apply multiple actions to a repository
class MultiBlob
  # rubocop:enable Metrics/ClassLength
  include ActiveModel::Model

  class Error < ::StandardError; end

  # Error class to hold the errors
  class ValidationFailed < Error
    attr_reader :conflicts, :errors
    def initialize(errors: nil, conflicts: nil)
      @errors = errors
      @conflicts = conflicts
      super(@errors.messages.to_json)
    end
  end

  ENCODINGS = %w(base64 plain).freeze

  attr_reader :errors

  # Only used for +save+
  attr_accessor :branch, :commit_message, :files, :last_known_head_id,
                :repository, :user

  # Created during +save+
  attr_accessor :decorated_file_versions, :commit_sha

  def initialize(*args)
    super(*args)
    @errors = ActiveModel::Errors.new(self)
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def save
    normalize_params
    raise ValidationFailed, errors: @errors unless valid?
    self.commit_sha =
      begin
        GitHelper.exclusively(repository) do
          git.commit_multichange(commit_info, last_known_head_id)
        end
      rescue Bringit::Committing::HeadChangedError => e
        @errors.add(:branch,
                    'Could not save the file in the git repository '\
                    'because it has changed in the meantime. '\
                    'Please try again after checking out the current revision.')
        raise ValidationFailed, errors: @errors, conflicts: e.conflicts
      rescue TypeError => e
        raise unless e.message.match?(/Expecting a String or Rugged::Reference/)
        @errors.add(:last_known_head_id, 'reference could not be found')
        raise ValidationFailed, errors: @errors
      end
    self.decorated_file_versions = create_decorated_file_versions(commit_sha)
    ProcessCommitJob.perform_later(repository.id, commit_sha)
    commit_sha
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def git
    @git ||= repository&.git
  end

  protected

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/BlockLength
  # This restricts the user-supplied params to those that are allowed by the
  # git library.
  def normalize_params
    files.map! do |file|
      case file[:action].to_sym
      when :create
        {path: file[:path],
         content: file[:content],
         encoding: file[:encoding],
         action: :create}
      when :update
        {path: file[:path],
         content: file[:content],
         encoding: file[:encoding],
         action: :update}
      when :rename_and_update
        {path: file[:new_path],
         previous_path: file[:path],
         content: file[:content],
         encoding: file[:encoding],
         action: :rename_and_update}
      when :rename
        {path: file[:new_path],
         previous_path: file[:path],
         action: :rename}
      when :remove
        {path: file[:path],
         action: :remove}
      when :mkdir
        {path: file[:path],
         action: :mkdir}
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/BlockLength

  # rubocop:disable Style/IfUnlessModifier
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/BlockLength
  def valid?
    return @errors.blank? if @validated
    files.each_with_index do |file, index|
      prefix = "files/#{index}/"

      if file[:path].blank?
        field = file[:action].to_s.match?(/\Arename/) ? 'new_path' : 'path'
        @errors.add("#{prefix}#{field}", 'must be present')
      end

      case file[:action]
      when :create
        if path_exists?(file[:path])
          @errors.add("#{prefix}path",
                      "path already exists: #{file[:path]}")
        end
      when :update
        if path_does_not_exist?(file[:path])
          @errors.add("#{prefix}path",
                      "path does not exist: #{file[:path]}")
        end
      when :rename_and_update
        # `path` from the GraphQL API is mapped to `previous_path` of
        # Bringit.
        if file[:previous_path].blank?
          @errors.add("#{prefix}path", 'must be present')
        elsif path_does_not_exist?(file[:previous_path])
          @errors.add("#{prefix}path",
                      "path does not exist: #{file[:previous_path]}")
        elsif file[:previous_path] == file[:path]
          @errors.add("#{prefix}new_path", 'path and new_path must differ')
        end
      when :rename
        # `path` from the GraphQL API is mapped to `previous_path` of
        # Bringit.
        if file[:previous_path].blank?
          @errors.add("#{prefix}path", 'must be present')
        elsif path_does_not_exist?(file[:previous_path])
          @errors.add("#{prefix}path",
                      "path does not exist: #{file[:previous_path]}")
        elsif file[:previous_path] == file[:path]
          @errors.add("#{prefix}new_path", 'path and new_path must differ')
        end
      when :remove
        if path_does_not_exist?(file[:path])
          @errors.add("#{prefix}path",
                      "path does not exist: #{file[:path]}")
        end
      when :mkdir
        if path_exists?(file[:path])
          @errors.add("#{prefix}path",
                      "path already exists: #{file[:path]}")
        end
      end

      # rubocop:disable Style/Next
      if %i(create update rename_and_update).include?(file[:action])
        # rubocop:enable Style/Next
        if file[:content].nil?
          @errors.add("#{prefix}content", 'must exist')
        end
        unless file[:content].is_a?(String)
          @errors.add("#{prefix}content", 'must be a string')
        end

        if !ENCODINGS.include?(file[:encoding]) && !file[:content].nil?
          @errors.add("#{prefix}encoding",
                      "encoding not supported: #{file[:encoding]}. "\
                      "Must be one of #{ENCODINGS.join(',')}")
        end
      end
    end

    unless repository.is_a?(RepositoryCompound)
      @errors.add(:repository, 'must be a repository')
    end
    unless user.is_a?(User)
      @errors.add(:user, 'must be a user')
    end
    if !git&.empty? && !git&.branch_exists?(branch)
      @errors.add(:branch, "branch does not exist: #{branch}")
    end
    unless commit_message.present?
      @errors.add(:commit_message, 'must be present')
    end

    @validated = true
    @errors.blank?
  end
  # rubocop:enable Style/IfUnlessModifier
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/BlockLength

  def path_exists?(path)
    branch_exists? && git&.path_exists?(branch, path)
  end

  def path_does_not_exist?(path)
    branch_exists? && !git&.path_exists?(branch, path)
  end

  def branch_exists?
    !git&.empty? && git&.branch_exists?(branch)
  end

  def create_decorated_file_versions(commit_sha)
    files.map do |file|
      create_decorated_file_version(commit_sha, file)
    end.compact
  end

  def create_decorated_file_version(commit_sha, file)
    action = file[:action]
    applied_action = action == :mkdir ? :created : :"#{action}d"
    if action == :remove
      {action: applied_action, path: file[:path]}
    elsif %i(create update rename_and_update rename mkdir).include?(action)
      file_version = create_file_version(commit_sha, file)
      {action: applied_action, file_version: file_version}
    end
  end

  def create_file_version(commit_sha, file)
    options = file_options(file)
    Sequel::Model.db.transaction do
      action = Action.create(evaluation_state: 'not_yet_enqueued')
      FileVersion.create(options.merge(action_id: action.id,
                                       commit_sha: commit_sha,
                                       repository_id: repository.pk))
    end
  end

  def file_options(file)
    path =
      if file[:action] == :mkdir
        File.join(file[:path], '.gitkeep')
      else
        file[:path]
      end
    {path: path}
  end

  def commit_info
    user_info_hash = GitHelper.git_user(user, Time.now)
    @commit_info ||= {files: files,
                      author: user_info_hash,
                      committer: user_info_hash,
                      commit: {message: commit_message, branch: branch}}
  end
end
