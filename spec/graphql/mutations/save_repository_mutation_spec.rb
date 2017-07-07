# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'saveRepository mutation' do
  let!(:repository) { create :repository_compound }
  let(:repository_data) do
    repo = build :repository
    data = repo.values.slice(:description, :content_type, :public_access).
      transform_keys { |k| k.to_s.camelize(:lower) }
    data['visibility'] = data['publicAccess'] ? 'public' : 'private'
    data.delete('publicAccess')
    data
  end

  let(:context) { {} }
  let(:variables) { {'id' => repository.to_param, 'data' => repository_data} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation SaveRepository($id: ID!, $data: RepositoryChangeset!) {
      saveRepository(id: $id, data: $data) {
        id
        description
        visibility
        contentType
      }
    }
    QUERY
  end

  subject { result }

  context 'Successful update' do
    it 'returns the repository fields' do
      expect(subject['data']['saveRepository']).to include(
        'id' => repository.to_param,
        'description' => repository_data['description'],
        'contentType' => repository_data['contentType'],
        'visibility' => repository_data['visibility']
      )
    end
  end

  context 'Repository does not exist' do
    let(:variables) do
      {'id' => "bad-#{repository.to_param}",
       'data' => repository_data}
    end

    it 'returns an error' do
      expect(subject['data']['saveRepository']).to be_nil
      expect(subject['errors']).
        to include(include('message' => 'resource not found'))
    end
  end
end
