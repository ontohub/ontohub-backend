# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessCommitJob, type: :job do
  describe 'perform' do
    let(:repository_id) { 1 }
    let(:commit_sha) { '0' * 40 }
    let(:file_version_parents_creator) { double(:file_version_parents_creator) }

    before do
      # Stub the FileVersionParentsCreator
      allow(FileVersionParentsCreator).
        to receive(:new).
        with(repository_id, commit_sha).
        and_return(file_version_parents_creator)

      allow(file_version_parents_creator).
        to receive(:call)

      # Run the job
      ProcessCommitJob.new.perform(repository_id, commit_sha)
    end

    it 'calls the FileVersionParentsCreator' do
      expect(file_version_parents_creator).
        to have_received(:call)
    end
  end
end
