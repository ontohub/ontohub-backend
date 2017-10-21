# frozen_string_literal: true

module HetsAgent
  # Builds arguments (a "request") for the HetsAgent application.
  class ReanalysisRequestCollection < AnalysisRequestCollection
    include Enumerable

    attr_reader :commit_sha, :file_version, :repository

    delegate :each, to: :requests

    def initialize(file_version)
      @commit_sha = file_version.commit_sha
      @file_version = file_version
      @repository = RepositoryCompound.first!(id: file_version.repository_id)
    end

    def requests
      @requests ||= [arguments(file_version)]
    end
  end
end
