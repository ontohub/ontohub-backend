# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'deleteRepository mutation' do
  let!(:repository) { create :repository_compound }

  let(:context) { {} }
  let(:variables) { {'id' => repository.to_param} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation DeleteRepository($id: ID!) {
      deleteRepository(id: $id)
    }
    QUERY
  end

  subject { result }

  context 'Successful delete' do
    it 'returns true' do
      expect(subject['data']['deleteRepository']).to be(true)
    end

    it 'deletes the repository' do
      subject
      repo = Repository.find(slug: repository.slug)
      expect(repo).to be_nil
    end

    it 'deletes the git repository' do
      subject
      expect(repository.git.repo_exists?).to be(false)
    end
  end

  context 'Repository does not exist' do
    let(:variables) { {'id' => repository.to_param + 'foo'} }

    it 'returns an error' do
      expect(subject['data']['deleteRepository']).to be_nil
      expect(subject['errors']).
        to include(include('message' => 'resource not found'))
    end
  end
end
