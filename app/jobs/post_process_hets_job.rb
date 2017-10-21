# frozen_string_literal: true

# Post-processes a finished job that was sent to Hets
class PostProcessHetsJob < ApplicationJob
  queue_as :post_process_hets

  def perform(result, original_job_message)
    return unless result == 'success'

    post_processing_result = post_process(JSON.parse(original_job_message))
    requeue(result, original_job_message) if post_processing_result == :requeue
    post_processing_result
  end

  protected

  def post_process(parsed_original_job)
    case parsed_original_job['action']
    when 'analysis'
      ImportingDocumentsReanalyzer.
        new(parsed_original_job['arguments']['file_version_id']).call
    end
  end

  def requeue(*job_arguments)
    # 10 Seconds is just an arbitrary value. We need to wait for the analysis
    # jobs to finish before we can try to post-process this one again.
    sleep 10
    PostProcessHetsJob.perform_later(*job_arguments)
  end
end
