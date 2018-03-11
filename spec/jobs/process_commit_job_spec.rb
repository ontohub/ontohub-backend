# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessCommitJob, type: :job do
  describe 'perform' do
    let(:repository) { create(:repository_compound) }
    let(:commit_sha) { '0' * 40 }
    let(:file_versions) do
      create_list(:file_version, 2,
                  repository: repository,
                  commit_sha: commit_sha)
    end
    let(:file_version_parents_creator) { double(:file_version_parents_creator) }
    let(:analysis_request_collection) { double(:analysis_request_collection) }
    let(:hets_agent_invoker) { double(:hets_agent_invoker) }

    before do
      # Stub the FileVersionParentsCreator
      allow(FileVersionParentsCreator).
        to receive(:new).
        with(repository.id, commit_sha).
        and_return(file_version_parents_creator)

      allow(file_version_parents_creator).
        to receive(:call)

      allow(analysis_request_collection).
        to receive(:map).
        and_return([file_versions.first.id])

      # Stub the HetsAgent::AnalysisRequestCollection
      allow(HetsAgent::AnalysisRequestCollection).
        to receive(:new).
        with(repository.id, commit_sha).
        and_return(analysis_request_collection)

      # Stub the HetsAgent::Invoker
      allow(HetsAgent::Invoker).
        to receive(:new).
        with(analysis_request_collection).
        and_return(hets_agent_invoker)

      allow(hets_agent_invoker).
        to receive(:call)

      # Run the job
      ProcessCommitJob.new.perform(repository.id, commit_sha)
    end

    it 'creates the FileVersionParentsCreator' do
      expect(FileVersionParentsCreator).
        to have_received(:new).
        with(repository.id, commit_sha)
    end

    it 'calls the FileVersionParentsCreator' do
      expect(file_version_parents_creator).
        to have_received(:call)
    end

    it 'sets the non-document-file versions finished' do
      finished_file_version_ids =
        FileVersion.join(:actions,
                         Sequel[:file_versions][:action_id] =>
                           Sequel[:actions][:id]).
          where(evaluation_state: 'finished_successfully').map(:id)
      expect(finished_file_version_ids).to eq([file_versions.last.id])
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
