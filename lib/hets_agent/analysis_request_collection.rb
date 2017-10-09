# frozen_string_literal: true

module HetsAgent
  # Finds all files that have been changed in a commit and builds corresponding
  # arguments (a "request") for the HetsAgent application.
  class AnalysisRequestCollection
    include Enumerable

    attr_reader :commit_sha, :git, :repository

    delegate :each, to: :requests

    def initialize(repository_id, commit_sha)
      @commit_sha = commit_sha
      @repository = RepositoryCompound.find(id: repository_id)
      @git = @repository.git
    end

    def requests
      return @requests unless @requests.nil?

      @requests = []
      git.diff_from_parent(commit_sha).each do |diff|
        request = hets_agent_arguments(diff)
        @requests << request unless request.nil?
      end

      @requests
    end

    protected

    # rubocop:disable Metrics/MethodLength
    def hets_agent_arguments(diff)
      # rubocop:enable Metrics/MethodLength
      return if diff.deleted_file

      file_path = diff.new_path
      return unless file_path

      file_version_id = FileVersion.first!(commit_sha: commit_sha,
                                           path: file_path).id

      {
        action: 'analysis',
        arguments: {
          server_url: Settings.server_url,
          repository_slug: repository.to_param,
          revision: commit_sha,
          file_path: file_path,
          file_version_id: file_version_id,
          url_mappings: [],
        },
      }
    end
  end
end
