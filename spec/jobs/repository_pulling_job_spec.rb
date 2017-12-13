# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepositoryPullingJob, type: :job do
  let(:repository) { create :repository, :mirror }
  let(:path) do
    RepositoryCompound.git_directory.join("#{repository.to_param}.git")
  end

  let(:bringit_double) { double(:bringit) }
  before do
    # Stub the Bringit::Wrapper
    allow(Bringit::Wrapper).
      to receive(:new).
      with(path).
      and_return(bringit_double)

    allow(bringit_double).
      to receive(:pull)

    allow(bringit_double).
      to receive(:path).
      and_return(path)

    # Run the job
    RepositoryPullingJob.new.perform(repository.to_param)
  end

  it 'pulls the git repository' do
    expect(bringit_double).
      to have_received(:pull)
  end

  it 'sets the pulling timestamp' do
    expect(repository.reload.synchronized_at).not_to be(nil)
  end
end
