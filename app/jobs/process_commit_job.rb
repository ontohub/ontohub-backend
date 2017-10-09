# frozen_string_literal: true

# Post-processes a single commit
class ProcessCommitJob < ApplicationJob
  queue_as :process_commit

  def perform(repository_id, commit_sha)
    FileVersionParentsCreator.new(repository_id, commit_sha).call
    request_collection =
      HetsAgent::AnalysisRequestCollection.new(repository_id, commit_sha)
    HetsAgent::Invoker.new(request_collection).call
  end
end
