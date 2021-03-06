# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'deleteBranch mutation' do
  let!(:user) { create :user }
  let!(:repository) { create :repository_compound, :not_empty, owner: user }
  let(:name) { generate(:branchname) }
  let(:name_argument) { name }
  let(:revision) { 'master' }

  let(:context) { {current_user: user} }
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

    context 'because the repository is private' do
      let!(:repository) { create(:repository_compound, :private, :not_empty) }
      let(:context) { {} }

      it 'returns no data' do
        expect(subject['data']['deleteBranch']).to be(nil)
      end

      it 'returns an error' do
        expect(subject['errors']).
          to include(include('message' => 'resource not found'))
      end
    end

    context 'because the user is not signed in' do
      let(:context) { {} }

      it 'returns no data' do
        expect(subject['data']['deleteBranch']).to be(nil)
      end

      it 'returns an error' do
        expect(subject['errors']).
          to include(include('message' => "You're not authorized to do this"))
      end
    end
  end
end
