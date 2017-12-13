# frozen_string_literal: true

# Git pull finished job that was sent to Hets
class RepositoryPullingJob < ApplicationJob
  queue_as :git_pull

  def perform(repository_slug)
    repository = RepositoryCompound.first(slug: repository_slug)
    path = RepositoryCompound.git_directory.join("#{repository.to_param}.git")
    GitHelper.exclusively(repository) { Bringit::Wrapper.new(path).pull }
    repository.update(synchronized_at: Time.now)
  end
end
