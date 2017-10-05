# frozen_string_literal: true

# A service class that finds the new files of a commit and invokes the HetsAgent
# to analyze them.
class HetsAgentInvoker
  WORKER_QUEUE_NAME =
    "hets #{OntohubBackend::Application.config.hets_version_requirement}"

  attr_reader :commit_sha, :connection, :git, :repository

  def initialize(repository_id, commit_sha)
    @commit_sha = commit_sha
    @repository = RepositoryCompound.find(id: repository_id)
    @git = @repository.git
    @connection = Sneakers::CONFIG[:connection]
  end

  def call
    connection.start
    queue = create_worker_queue(connection)
    git.diff_from_parent(commit_sha).each do |diff|
      arguments = hets_agent_arguments(diff)
      queue.publish(arguments.to_json) if arguments
    end
  ensure
    connection.close
  end

  protected

  def create_worker_queue(connection)
    channel = connection.create_channel
    channel.queue(WORKER_QUEUE_NAME,
                  durable: true,
                  auto_delete: false)
  end

  # rubocop:disable Metrics/MethodLength
  def hets_agent_arguments(diff)
    # rubocop:enable Metrics/MethodLength
    return if diff.deleted_file

    file_path = diff.new_path
    return unless file_path

    file_version_id = FileVersion.find(commit_sha: commit_sha,
                                       path: file_path)&.id
    {
      action: 'analysis',
      arguments: {
        server_url: Settings.server_url,
        repository_slug: repository.to_param,
        revision: commit_sha,
        file_path: file_path,
        file_version_id: file_version_id,
        url_mappings: {},
      },
    }
  end
end
