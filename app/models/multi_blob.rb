# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

# Allows to apply multiple actions to a repository
class MultiBlob < ActiveModelSerializers::Model
  class Error < ::StandardError; end
  class ValidationFailed < Error; end

  ENCODINGS = %w(base64 plain).freeze

  # Only used for +save+
  attr_accessor :branch, :commit_message, :files, :previous_head_sha,
                :repository, :user

  # Created during +save+
  attr_accessor :decorated_file_versions, :commit_sha

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def save
    normalize_params
    raise ValidationFailed, @errors.messages.to_json unless valid?
    self.commit_sha =
      begin
        git.commit_multichange(commit_info, previous_head_sha)
      rescue Gitlab::Git::Committing::HeadChangedError
        @errors.add(:branch,
                    'Could not save the file in the git repository '\
                    'because it has changed in the meantime. '\
                    'Please try again after checking out the current revision.')
        raise ValidationFailed, @errors.messages.to_json
      end
    self.decorated_file_versions = create_decorated_file_versions(commit_sha)
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
        options =
          {path: file[:path],
           content: file[:content],
           encoding: file[:encoding],
           action: :update}
        unless file[:previous_path].nil?
          options[:previous_path] = file[:previous_path]
        end
        options
      when :rename
        {path: file[:path],
         previous_path: file[:previous_path],
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
        @errors.add("#{prefix}path", 'must be present')
      end

      case file[:action]
      when :create
        if path_exists?(file[:path])
          @errors.add("#{prefix}path",
                      "path already exists: #{file[:path]}")
        end
      when :update
        if !file[:previous_path].nil?
          if file[:previous_path].blank?
            @errors.add("#{prefix}previous_path", 'must be present')
          elsif path_does_not_exist?(file[:previous_path])
            @errors.add("#{prefix}previous_path",
                        "path does not exist: #{file[:previous_path]}")
          elsif file[:previous_path] == file[:path]
            @errors.add("#{prefix}path", 'previous_path and path must differ')
          end
        elsif path_does_not_exist?(file[:path])
          @errors.add("#{prefix}path",
                      "path does not exist: #{file[:path]}")
        end
      when :rename
        if file[:previous_path].blank?
          @errors.add("#{prefix}previous_path", 'must be present')
        elsif path_does_not_exist?(file[:previous_path])
          @errors.add("#{prefix}previous_path",
                      "path does not exist: #{file[:previous_path]}")
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
      if %i(create update).include?(file[:action])
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
    elsif %i(create update rename mkdir).include?(action)
      file_version = create_file_version(commit_sha, file)
      {action: applied_action, file_version: file_version}
    end
  end

  def create_file_version(commit_sha, file)
    options = file_options(file)
    fv = FileVersion.new(options.merge(commit_sha: commit_sha,
                                       repository_id: repository.pk))
    fv.save
    fv
  end

  def file_options(file)
    path = file[:action] == :mkdir ? "#{file[:path]}/.gitkeep" : file[:path]
    {path: path,
     url_path_method: ->(file_version) { url_path(file_version) }}
  end

  def url_path(file_version)
    ['', # this empty string adds the leading slash
     repository.to_param,
     'ref', file_version.commit_sha,
     'tree', file_version.path].join('/')
  end

  def commit_info
    user_info_hash = user_info(Time.now)
    @commit_info ||= {files: files,
                      author: user_info_hash,
                      committer: user_info_hash,
                      commit: {message: commit_message, branch: branch}}
  end

  def user_info(time = nil)
    {email: user.email,
     name: user.display_name || user.name,
     time: time || Time.now}
  end
end