# frozen_string_literal: true

module Rest
  # Handles requests for diff read operations
  class DiffsController < Rest::ApplicationController
    graphql :single_commit do
      arguments do
        organizational_unit_id = params[:organizational_unit_id]
        repository_id = params[:repository_id]

        {'repository' => "#{organizational_unit_id}/#{repository_id}",
         'revision' => params[:revision]}
      end

      query <<-QUERY
        query ($repository: ID!, $revision: ID!) {
          repository(id: $repository) {
            commit(revision: $revision) {
              diff {
                deletedFile
                diff
                lineCount
                newFile
                newMode
                newPath
                oldMode
                oldPath
                renamedFile
              }
            }
          }
        }
      QUERY
    end

    graphql :commit_range do
      arguments do
        organizational_unit_id = params[:organizational_unit_id]
        repository_id = params[:repository_id]

        {'repository' => "#{organizational_unit_id}/#{repository_id}",
         'from' => params[:from],
         'to' => params[:to],
         'paths' => Array(params[:paths])}
      end

      query <<-QUERY
        query ($repository: ID!, $from: ID!, $to: ID!, $paths: [String!]) {
          repository(id: $repository) {
            diff(from: $from, to: $to, paths: $paths) {
              deletedFile
              diff
              lineCount
              newFile
              newMode
              newPath
              oldMode
              oldPath
              renamedFile
            }
          }
        }
      QUERY
    end
  end
end
