# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepositoryCloningJob, type: :job do
  let(:repository) { create :repository, :mirror}
  let(:path) do
    RepositoryCompound.git_directory.join("#{repository.to_param}.git")
  end

  before do
    # Stub the Bringit::Wrapper
    allow(Bringit::Wrapper).
      to receive(:clone).
      with(path.to_s, repository.remote_address)

    # Run the job
    RepositoryCloningJob.new.perform(repository.to_param)
  end

  it 'clones the git repository' do
    expect(Bringit::Wrapper).
      to have_received(:clone).
      with(path.to_s, repository.remote_address)
  end

  it 'sets the cloning timestamp' do
    expect(repository.reload.synchronized_at).not_to be(nil)
  end
end
