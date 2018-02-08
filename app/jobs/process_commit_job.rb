# frozen_string_literal: true

# Post-processes a single commit
class ProcessCommitJob < ApplicationJob
  queue_as 'process_commit'

  def perform(repository_id, commit_sha)
    FileVersionParentsCreator.new(repository_id, commit_sha).call
    request_collection =
      HetsAgent::AnalysisRequestCollection.new(repository_id, commit_sha)
    finish_non_documents(repository_id, commit_sha, request_collection)
    HetsAgent::Invoker.new(request_collection).call
  end

  protected

  def finish_non_documents(repository_id, commit_sha, requests)
    documents_ids = requests.map { |r| r[:arguments][:file_version_id] }
    all_file_versions = FileVersion.where(repository_id: repository_id,
                                          commit_sha: commit_sha)
    non_documents = all_file_versions.exclude(id: documents_ids)
    non_documents.update(evaluation_state: 'finished_successfully')
  end
end
