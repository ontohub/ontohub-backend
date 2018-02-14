# frozen_string_literal: true

# Worker for the git pull queue
class RepositoryPullingWorker < ApplicationWorker
  from_queue 'git_pull', threads: 4, prefetch: 1, timeout_job_after: nil,
    vhost: Settings.rabbitmq.virtual_host
end
