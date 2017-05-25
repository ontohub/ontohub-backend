# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
require 'base64'

# Represents a file in a git repository
class Blob < ActiveModelSerializers::Model
  include ActiveModel::Dirty

  class Error < ::StandardError; end
  class ValidationFailed < Error; end

  ENCODINGS = %w(base64 plain).freeze

  # Only used for +save+
  attr_accessor :branch, :commit_message, :previous_head_sha, :previous_path,
                :user

  # Only used for reading
  attr_accessor :commit_id, :id

  # Generally used
  attr_accessor :content, :encoding, :path, :repository

  # Record dirty state for these attributes
  define_attribute_methods :content, :path

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.find(args)
    repo = args[:repository] || Repository.find(slug: args[:repository_id])
    repository = RepositoryCompound.wrap(repo)

    blob = repository&.git&.blob(args[:branch], args[:path])
    unless blob.nil?
      new(content: blob.binary ? Base64.encode64(blob.data) : blob.data,
          encoding: blob.binary ? 'base64' : 'plain',
          commit_id: blob.commit_id,
          branch: args[:branch],
          id: blob.id,
          path: blob.path,
          repository: repository)
    end
  rescue Rugged::ReferenceError
    nil
  end

  def initialize(params)
    super(params)
    return unless commit_id && git&.branch_exists?(commit_id)
    @commit_id = git&.branch_sha(commit_id)
  end

  def update(params)
    self.previous_path ||= path if params.keys.map(&:to_sym).include?(:path)
    params.each do |field, value|
      send("#{field}_will_change!") if %w(content path).include?(field.to_s)
      attributes[field] = value
      send("#{field}=", value)
    end
    reset_validation_state
    valid?(:update)
    true
  end

  def create
    reset_validation_state
    valid?(:create)
    save(mode: :create)
  end

  def destroy
    self.commit_message = attributes[:commit_message] = "Delete #{path}."
    git.remove_file(commit_info, previous_head_sha)
  rescue Gitlab::Git::Repository::InvalidRef
    @errors.add(:branch, "branch does not exist: #{branch}")
    raise ValidationFailed
  end

  def save(mode: nil)
    raise ValidationFailed, @errors.messages.to_json unless valid?
    commit_sha =
      begin
        if rename_file?
          git.rename_file(commit_info, previous_head_sha)
        elsif mode == :create
          git.create_file(commit_info, previous_head_sha)
        else
          git.update_file(commit_info, previous_head_sha)
        end
      rescue Gitlab::Git::Committing::HeadChangedError
        @errors.add(:branch,
                    'Could not save the file in the git repository '\
                    'because it has changed in the meantime. '\
                    'Please try again after checking out the current revision.')
        raise ValidationFailed
      end
    self.commit_id = commit_sha
    create_file_version(commit_sha)

    changes_applied

    true
  end

  def git
    @git ||= repository&.git
  end

  def url(prefix)
    "#{prefix.sub(%r{/$}, '')}#{url_path}"
  end

  def url_path
    ['', # this empty string adds the leading slash
     repository.to_param,
     'ref', commit_id,
     'tree', path].join('/')
  end

  protected

  def rename_file?
    previous_path.present? && previous_path != path
  end

  # rubocop:disable Style/IfUnlessModifier
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def valid?(mode = :save)
    return @errors.blank? if @validated
    case mode
    when :create
      if !git&.empty? && git&.branch_exists?(branch) &&
         git&.path_exists?(branch, path)
        @errors.add(:path, "path already exists: #{path}")
      end
    when :update
      if !content_changed? && !path_changed?
        @errors.add(:content, 'either content or path must be changed')
      end
    end
    unless repository.is_a?(RepositoryCompound)
      @errors.add(:repository, 'repository must be set')
    end
    if user.blank?
      @errors.add(:user, 'No user set')
    end
    if !git&.empty? && !git&.branch_exists?(branch)
      @errors.add(:branch, "branch does not exist: #{branch}")
    end
    unless ENCODINGS.include?(encoding)
      @errors.add(:encoding, "encoding not supported: #{encoding}. "\
                           "Must be one of #{ENCODINGS.join(',')}")
    end
    if content.nil?
      @errors.add(:content, 'content must exist')
    end
    unless content.is_a?(String)
      @errors.add(:content, 'content must be a string')
    end
    unless commit_message.present?
      @errors.add(:commit_message, 'commit_message is not present')
    end
    @validated = true
    @errors.blank?
  end
  # rubocop:enable Style/IfUnlessModifier
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def reset_validation_state
    @errors.clear
    @validated = false
  end

  def decoded_content
    @decoded_content ||=
      case encoding
      when 'base64'
        Base64.decode64(content)
      when 'plain'
        content
      end
  end

  def create_file_version(commit_sha)
    file_version =
      FileVersion.new(path: path,
                      commit_sha: commit_sha,
                      repository_id: repository.pk,
                      url_path_method: ->(_file_version) { url_path })
    file_version.save
    file_version
  end

  def commit_info
    now = Time.now
    @commit_info ||= {file: {content: decoded_content, path: path},
                      author: user_info(now),
                      committer: user_info(now),
                      commit: {message: commit_message, branch: branch}}
    @commit_info[:file][:previous_path] = previous_path if rename_file?
    @commit_info
  end

  def user_info(time = nil)
    {email: user.email,
     name: user.display_name || user.slug,
     time: time || Time.now}
  end
end
