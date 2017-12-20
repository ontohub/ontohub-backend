# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepositoryPullingPeriodicallyJob, type: :job do
  let!(:repository_mirror1) { create :repository, :mirror }
  let!(:repository_mirror2) { create :repository, :mirror }
  let!(:repository_fork) { create :repository, :fork }

  it 'sets the time for the job to be scheduled' do
    expect do
      RepositoryPullingPeriodicallyJob.new.perform
    end.to have_enqueued_job(RepositoryPullingPeriodicallyJob)
  end

  shared_examples 'pulls two repositories that are mirrors' do
    it 'pulls every mirror' do
      expect do
        RepositoryPullingPeriodicallyJob.new.perform
      end.to have_enqueued_job(RepositoryPullingJob).
        with(repository.to_param)
    end
  end

  include_examples 'pulls two repositories that are mirrors' do
    let(:repository) { repository_mirror1 }
  end

  include_examples 'pulls two repositories that are mirrors' do
    let(:repository) { repository_mirror2 }
  end

  context 'does not pull a fork repository' do
    it 'does not pull fork mirror' do
      expect do
        RepositoryPullingPeriodicallyJob.new.perform
      end.not_to have_enqueued_job(RepositoryPullingJob).
        with(repository_fork.to_param)
    end
  end
end
