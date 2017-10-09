# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessCommitJob, type: :job do
  describe 'perform' do
    let(:repository_id) { 1 }
    let(:commit_sha) { '0' * 40 }
    let(:file_version_parents_creator) { double(:file_version_parents_creator) }
    let(:analysis_request_collection) { double(:analysis_request_collection) }
    let(:hets_agent_invoker) { double(:hets_agent_invoker) }

    before do
      # Stub the FileVersionParentsCreator
      allow(FileVersionParentsCreator).
        to receive(:new).
        with(repository_id, commit_sha).
        and_return(file_version_parents_creator)

      allow(file_version_parents_creator).
        to receive(:call)

      # Stub the HetsAgent::AnalysisRequestCollection
      allow(HetsAgent::AnalysisRequestCollection).
        to receive(:new).
        with(repository_id, commit_sha).
        and_return(analysis_request_collection)

      # Stub the HetsAgent::Invoker
      allow(HetsAgent::Invoker).
        to receive(:new).
        with(analysis_request_collection).
        and_return(hets_agent_invoker)

      allow(hets_agent_invoker).
        to receive(:call)

      # Run the job
      ProcessCommitJob.new.perform(repository_id, commit_sha)
    end

    it 'calls the FileVersionParentsCreator' do
      expect(file_version_parents_creator).
        to have_received(:call)
    end

    it 'creates the HetsAgentInvoker' do
      expect(HetsAgent::Invoker).
        to have_received(:new).
        with(analysis_request_collection)
    end

    it 'calls the HetsAgentInvoker' do
      expect(hets_agent_invoker).
        to have_received(:call)
    end
  end
end
