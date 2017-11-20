# frozen_string_literal: true

module Rest
  # Handles requests for branch read operations
  class DocumentsController < Rest::ApplicationController
    # rubocop:disable Metrics/BlockLength
    graphql :show do
      # rubocop:enable Metrics/BlockLength
      arguments do
        organizational_unit_id = params[:organizational_unit_id]
        repository_id = params[:repository_id]
        {'repository' => "#{organizational_unit_id}/#{repository_id}",
         'revision' => params[:revision],
         'documentLocId' => params[:document_loc_id]}
      end

      query <<-QUERY
        query ($repository: ID!, $revision: ID, $documentLocId: ID!) {
          repository(id: $repository) {
            commit(revision: $revision) {
              document(locId: $documentLocId) {
                __typename
                locId
                documentLinks {
                  source {
                    __typename
                    locId
                  }
                  target {
                    __typename
                    locId
                  }
                }
              }
            }
          }
        }
      QUERY

      plain do |_graphql_executor, variables, _context|
        repository = RepositoryCompound.first(slug: variables['repository'])
        git = repository.git
        commit = git.commit(variables['revision'] || git.default_branch)
        document =
          Document.where_commit_sha(commit_sha: commit&.id,
                                    loc_id: variables['documentLocId']).first
        if document
          path = document.file_version.path
          content = GitFile.new(commit, path, load_all_data: true).content
          [content, :ok]
        else
          ['', :not_found]
        end
      end
    end
  end
end
