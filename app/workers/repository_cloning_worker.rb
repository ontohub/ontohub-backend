# frozen_string_literal: true

# Worker for the git clone queue
class RepositoryCloningWorker < ApplicationWorker
  from_queue :git_clone, threads: 4, prefetch: 1, timeout_job_after: nil
end
