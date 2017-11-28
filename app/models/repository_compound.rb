# frozen_string_literal: true

# This class combines the Repository model and the Git library.
# It forwards model methods directly to the Repository object.
class RepositoryCompound
  class << self
    %i(find first first!).each do |method|
      define_method(method) do |*args|
        repository = Repository.public_send(method, *args)
        wrap(repository) if repository
      end
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
      new = repository.new?
      repository.save
      @git = Bringit::Wrapper.create(git_path) if repository.exists? && new
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
    @git ||= Bringit::Wrapper.new(git_path) unless repository.nil?
  end

  def ==(other)
    repository == other.repository
  end

  protected

  def git_path
    self.class.git_directory.join("#{repository.to_param}.git")
  end
end
