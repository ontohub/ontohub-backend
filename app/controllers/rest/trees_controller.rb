# frozen_string_literal: true

module Rest
  # Handles requests for branch read operations
  class TreesController < Rest::ApplicationController
    # rubocop:disable Metrics/BlockLength
    graphql :show do
      # rubocop:enable Metrics/BlockLength
      arguments do
        organizational_unit_id = params[:organizational_unit_id]
        repository_id = params[:repository_id]
        {'repository' => "#{organizational_unit_id}/#{repository_id}",
         'revision' => params[:revision],
         'path' => params[:path],
         'loadAllData' => ![nil, '', '0', 'false'].
           include?(params[:loadAllData])}
      end

      query <<-QUERY
        query ($repository: ID!, $revision: ID, $path: ID!, $loadAllData: Boolean!) {
          repository(id: $repository) {
            commit(revision: $revision) {
              file(path: $path, loadAllData: $loadAllData) {
                __typename
                name
                path
                size
                loadedSize
                encoding
                content
              }
              directory(path: $path) {
                __typename
                name
                path
              }
            }
          }
        }
      QUERY

      plain do |graphql_executor, variables, _context|
        variables['loadAllData'] = true
        result = graphql_executor.call
        text = result.dig('data', 'repository', 'commit', 'file', 'content')
        [text, text.nil? ? :not_found : :ok]
      end
    end
  end
end
