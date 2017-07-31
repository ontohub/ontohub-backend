# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'createBranch mutation' do
  let!(:repository) { create :repository_compound }
  let(:name) { "feature_#{Faker::Internet.user_name}" }
  let(:revision) { 'master' }

  let(:context) {}
  let(:variables) do
    {'repositoryId' => repository.to_param,
     'name' => name,
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
    mutation ($repositoryId: ID!, $name: String!, $revision: ID!) {
      createBranch(repositoryId: $repositoryId, name: $name, revision: $revision) {
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

  context 'Successful creation' do
    it 'returns the branch fields' do
      expect(subject['data']['createBranch']).to include(
        'name' => name,
        'target' => include('id' => repository.git.commit(revision).id)
      )
    end
    it 'creates the branch' do
      subject
      expect(repository.git.branch_names).to include(name)
    end
  end

  context 'Unsuccessful' do
    before do
      repository.git.create_branch(name, revision)
    end

    it 'returns no data' do
      expect(subject['data']['createBranch']).to be(nil)
    end

    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' => include('already exists')))
    end
  end
end