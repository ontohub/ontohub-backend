# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'createBranch mutation' do
  let!(:user) { create :user }
  let!(:repository) { create :repository_compound, :not_empty, owner: user }
  let(:git) { repository.git }
  let(:name) { generate(:branchname) }
  before do
    create(:branch, repository: repository,
                    name: name,
                    revision: 'master')
  end

  let(:context) { {current_user: user} }
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

    context 'because the user is not signed in' do
      let(:context) { {} }

      it 'returns no data' do
        expect(subject['data']['commit']).to be(nil)
      end

      it 'returns an error' do
        expect(subject['errors']).
          to include(include('message' => "You're not authorized to do this"))
      end
    end
  end
end
