# frozen_string_literal: true

# This class combines the Repository model and the Git library.
# It forwards model methods directly to the Repository object.
class RepositoryCompound < ActiveModelSerializers::Model
  attr_reader :git, :repository

  delegate *(Repository.instance_methods - Object.instance_methods),
           to: :repository
  class << self
    delegate :find, :where, to: Repository
  end

  def initialize(*repository_params)
    @repository = Repository.new(*repository_params)
  end
end
