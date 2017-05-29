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
    multi_blob = MultiBlob.new(multi_blob_params('remove'))
    multi_blob.save
  rescue MultiBlob::ValidationFailed
    convert_errors_and_raise(multi_blob)
  end

  def save(mode: nil)
    multi_blob =
      if mode == :create
        MultiBlob.new(multi_blob_params('create'))
      elsif rename_file? && content.nil?
        params = multi_blob_params('rename')
        reset_content
        MultiBlob.new(params)
      else
        MultiBlob.new(multi_blob_params('update'))
      end
    self.commit_id =
      begin
        multi_blob.save
      rescue MultiBlob::ValidationFailed
        convert_errors_and_raise(multi_blob)
      end

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
    !previous_path.nil?
  end

  def reset_validation_state
    @errors.clear
    @validated = false
  end

  def reset_content
    return unless content.nil?
    blob = repository.git.blob(branch, previous_path)
    self.content = blob.data
    self.encoding = blob.binary ? 'base64' : 'plain'
  end

  def multi_blob_params(mutli_blob_action)
    params = {files: [{path: path,
                       content: content,
                       encoding: encoding,
                       action: mutli_blob_action}],
              previous_head_sha: previous_head_sha,
              commit_message: commit_message,
              branch: branch,
              repository: repository,
              user: user}
    params[:files].first[:previous_path] = previous_path if rename_file?
    params
  end

  def convert_errors_and_raise(multi_blob)
    multi_blob.errors.messages.each do |attribute, messages|
      messages.each do |message|
        @errors.add(attribute.to_s.sub('files/0/', ''), message)
      end
    end
    raise ValidationFailed, @errors.messages.to_json
  end
end
