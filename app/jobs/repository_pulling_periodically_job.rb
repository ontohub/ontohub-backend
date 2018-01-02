# frozen_string_literal: true

# Git pull finished job that was sent to Hets
class RepositoryPullingPeriodicallyJob < ApplicationJob
  self.queue_adapter = :async
  queue_as :git_pull

  def perform
    Repository.where(remote_type: 'mirror').each do |repository|
      RepositoryPullingJob.perform_later(repository.slug)
    end
    RepositoryPullingPeriodicallyJob.
      set(wait: OntohubBackend::Application.
        config.mirror_repository_synchronization_interval).perform_later
  end
end
