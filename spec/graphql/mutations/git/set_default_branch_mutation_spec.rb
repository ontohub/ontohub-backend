# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'createBranch mutation' do
  let!(:repository) { create :repository_compound, :not_empty }
  let(:git) { repository.git }
  let(:name) { generate(:branchname) }
  before do
    create(:branch, repository: repository,
                    name: name,
                    revision: 'master')
  end

  let(:context) { {} }
  let(:variables) do
    {'repositoryId' => repository.to_param,
     'name' => name_argument}
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
      setDefaultBranch(repositoryId: $repositoryId, name: $name) {
        __typename
        name
        target {
          __typename
          id
        }
      }
    }
    QUERY
  end

  subject { result }

  context 'Successful' do
    let(:name_argument) { name }

    it 'returns the branch fields' do
      expect(subject['data']['setDefaultBranch']).to include(
        'name' => name,
        'target' => include('id' => git.commit(git.default_branch).id)
      )
    end
    it 'sets the default branch' do
      subject
      expect(git.default_branch).to eq(name)
    end
  end

  context 'Unsuccessful' do
    let(:name_argument) { 'inexistant' }

    it 'returns no data' do
      expect(subject['data']['setDefaultBranch']).to be(nil)
    end

    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' =>
                             %(The branch "#{name_argument}" does not exist.)))
    end
  end
end
