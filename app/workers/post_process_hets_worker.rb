# frozen_string_literal: true

# Worker for the commit queue
class PostProcessHetsWorker < ApplicationWorker
  from_queue :post_process_hets, threads: 1, prefetch: 1, timeout_job_after: nil
end
