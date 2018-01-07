# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PostProcessHetsJob, type: :job do
  let(:file_version) { create(:file_version) }
  let(:importing_documents_reanalyzer) { double(:reanalyzer) }
  let(:post_processing_result) { :done }
  let(:action) { 'analysis' }

  let(:original_job_message) do
    {'action' => action,
     'arguments' => {'file_version_id' => file_version.id}}
  end
  let(:job_message) { [result, original_job_message.to_json] }

  before do
    # Don't wait in the test
    allow_any_instance_of(PostProcessHetsJob).to receive(:sleep)

    # Don't call the actual post-processing
    allow(ImportingDocumentsReanalyzer).
      to receive(:new).
      with(file_version.id).
      and_return(importing_documents_reanalyzer)

    allow(importing_documents_reanalyzer).
      to receive(:call).
      and_return(post_processing_result)
  end

  context 'result: no success' do
    let(:result) { 'failure' }

    it 'returns nil' do
      expect(PostProcessHetsJob.new.perform(*job_message)).to be(nil)
    end

    it 'does not enqueue another job' do
      expect { PostProcessHetsJob.new.perform(*job_message) }.
        not_to have_enqueued_job
    end
  end

  context 'result: success' do
    let(:result) { 'success' }

    context 'unkown action' do
      let(:action) { 'unknown' }

      it 'returns nil' do
        expect(PostProcessHetsJob.new.perform(*job_message)).to be(nil)
      end

      it 'does not enqueue another job' do
        expect { PostProcessHetsJob.new.perform(*job_message) }.
          not_to have_enqueued_job
      end
    end

    context 'action: analysis' do
      context 'done' do
        it 'returns the post_processing_result' do
          expect(PostProcessHetsJob.new.perform(*job_message)).
            to eq(post_processing_result)
        end

        it 'does not sleep' do
          expect_any_instance_of(PostProcessHetsJob).not_to receive(:sleep)
          PostProcessHetsJob.new.perform(*job_message)
        end

        it 'does not enqueue another job' do
          expect { PostProcessHetsJob.new.perform(*job_message) }.
            not_to have_enqueued_job
        end

        it 'calls the ImportingDocumentsReanalyzer' do
          PostProcessHetsJob.new.perform(*job_message)
          expect(importing_documents_reanalyzer).to have_received(:call)
        end
      end

      context 'need to requeue' do
        let(:post_processing_result) { :requeue }

        it 'returns the post_processing_result' do
          expect(PostProcessHetsJob.new.perform(*job_message)).
            to eq(post_processing_result)
        end

        it 'sleeps' do
          expect_any_instance_of(PostProcessHetsJob).to receive(:sleep)
          PostProcessHetsJob.new.perform(*job_message)
        end

        it 'enqueues the same job again' do
          expect { PostProcessHetsJob.new.perform(*job_message) }.
            to have_enqueued_job.
            with(*job_message).
            on_queue("#{Settings.rabbitmq.prefix}_post_process_hets")
        end

        it 'calls the ImportingDocumentsReanalyzer' do
          PostProcessHetsJob.new.perform(*job_message)
          expect(importing_documents_reanalyzer).to have_received(:call)
        end
      end
    end
  end
end
