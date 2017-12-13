# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepositoryPullingPeriodicallyJob, type: :job do
  let!(:repository) { create :repository, :mirror }

  it 'pulls every mirror' do
    expect do
      RepositoryPullingPeriodicallyJob.new.perform
    end.to have_enqueued_job(RepositoryPullingJob).
      with(repository.to_param)
  end

  it 'sets the time for the job to be scheduled' do
    expect do
      RepositoryPullingPeriodicallyJob.new.perform
    end.to have_enqueued_job(RepositoryPullingPeriodicallyJob)
  end
  # add two mirrors to test if they were pulled and one
  # that is not a mirror
end
