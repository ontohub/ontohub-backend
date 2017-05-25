# frozen_string_literal: true

# This class combines the Repository model and the Git library.
# It forwards model methods directly to the Repository object.
class RepositoryCompound < ActiveModelSerializers::Model
  class << self
    def find(*args)
      repository = Repository.find(*args)
      wrap(repository) if repository
    end

    def where(*args)
      Repository.where(*args).map { |repository| wrap(repository) }
    end

    def wrap(repository)
      return repository if repository.is_a?(RepositoryCompound)
      # :nocov:
      # We only need this check for development as an assertion.
      unless repository.is_a?(Repository)
        raise "Object given to ##{__method__} is not a repository"
      end
      # :nocov:
      object = new
      object.instance_variable_set(:@repository, repository)
      object
    end

    def git_directory
      Settings.data_directory.join('git').freeze
    end
  end

  attr_reader :repository

  delegate :to_param, *(Repository.instance_methods - Object.instance_methods),
           to: :repository

  def initialize(*repository_params)
    @repository = Repository.new(*repository_params)
  end

  def save
    Sequel::Model.db.transaction do
      repository.save
      @git = Gitlab::Git::Wrapper.create(git_path) if repository.exists?
      true
    end
  end

  def destroy
    Sequel::Model.db.transaction do
      repository.destroy
      git.path.rmtree if git.path.exist?
      true
    end
  end

  def git
    @git ||= Gitlab::Git::Wrapper.new(git_path) unless repository.nil?
  end

  def url(prefix)
    "#{prefix.sub(%r{/$}, '')}#{url_path}"
  end

  def url_path
    "/#{repository.to_param}"
  end

  protected

  def git_path
    self.class.git_directory.join("#{repository.to_param}.git")
  end
end
