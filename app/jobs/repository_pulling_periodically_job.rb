# frozen_string_literal: true

# Git pull finished job that was sent to Hets
class RepositoryPullingPeriodicallyJob < ApplicationJob
  self.queue_adapter = :async
  queue_as :git_pull

  def perform
    repository = Repository.entries
    repository.each do |repository_slug|
      RepositoryPullingJob.perform(repository_slug)
    end
    RepositoryPullingPeriodicallyJob.
      set(wait: OntohubBackend::Application.
        config.mirror_repository_synchronization_interval).perform_later
  end
end
