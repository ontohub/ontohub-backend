# frozen_string_literal: true

# This class combines the Repository model and the Git library.
# It forwards model methods directly to the Repository object.
class RepositoryCompound < ActiveModelSerializers::Model
  GIT_DIRECTORY = Settings.data_directory.join('git').freeze

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
      object = new
      object.instance_variable_set(:@repository, repository)
      object
    end
  end

  attr_reader :repository

  delegate :to_param, *(Repository.instance_methods - Object.instance_methods),
           to: :repository

  def initialize(*repository_params)
    @repository = Repository.new(*repository_params)
  end

  def save
    repository.save
    @git = Git.create(git_path) if repository.exists?
    true
  end

  def destroy
    repository.destroy
    git.path.rmtree if git.path.exist?
    true
  end

  def git
    @git ||= Git.new(git_path) unless repository.nil?
  end

  def url(prefix)
    "#{prefix.sub(%r{/$}, '')}#{url_path}"
  end

  def url_path
    "/#{repository.to_param}"
  end

  protected

  def git_path
    GIT_DIRECTORY.join("#{repository.to_param}.git")
  end
end
