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
      @repository = RepositoryCompound.first!(id: repository_id)
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

    def hets_agent_arguments(diff)
      return if diff.deleted_file

      file_path = diff.new_path
      return unless file_path
      unless OntohubBackend::Application.config.document_file_extensions.
          include?(File.extname(file_path))
        return
      end

      file_version = FileVersion.first!(commit_sha: commit_sha,
                                        path: file_path)
      arguments(file_version)
    end

    # rubocop:disable Metrics/MethodLength
    def arguments(file_version)
      # rubocop:enable Metrics/MethodLength
      {
        action: 'analysis',
        arguments: {
          server_url: Settings.server_url,
          repository_slug: repository.to_param,
          revision: commit_sha,
          file_path: file_version.path,
          file_version_id: file_version.id,
          url_mappings: url_mappings,
        },
      }
    end

    def url_mappings
      repository.url_mappings.map do |url_mapping|
        {url_mapping.source => url_mapping.target}
      end
    end
  end
end
