# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'deleteBranch mutation' do
  let!(:repository) { create :repository_compound }
  let(:name) { generate(:branchname) }
  let(:name_argument) { name }
  let(:revision) { 'master' }

  let(:context) {}
  let(:variables) do
    {'repositoryId' => repository.to_param,
     'name' => name_argument,
     'revision' => revision}
  end

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation ($repositoryId: ID!, $name: String!) {
      deleteBranch(repositoryId: $repositoryId, name: $name)
    }
    QUERY
  end

  subject { result }

  before do
    create(:branch, name: name, revision: revision, repository: repository)
  end

  context 'Successful deletion' do
    it 'returns true' do
      expect(subject['data']['deleteBranch']).to be(true)
    end

    it 'deletes the branch' do
      subject
      expect(repository.git.branch_names).not_to include(name)
    end
  end

  context 'Unsuccessful' do
    let(:name_argument) { "not_the_#{name}" }
    it 'returns true' do
      expect(subject['data']['deleteBranch']).to be(true)
    end

    it 'returns no error' do
      expect(subject['errors']).to be(nil)
    end

    it 'does not delete the branch' do
      subject
      expect(repository.git.branch_names).to include(name)
    end
  end
end
