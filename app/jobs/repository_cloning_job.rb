# frozen_string_literal: true

# Git clone finished job that was sent to Hets
class RepositoryCloningJob < ApplicationJob
  queue_as 'git_clone'

  def perform(repository_slug)
    repository = Repository.first(slug: repository_slug)
    path = RepositoryCompound.git_directory.join("#{repository.to_param}.git")
    Bringit::Wrapper.clone(path.to_s, repository.remote_address)
    repository.update(synchronized_at: Time.now)
  end
end
