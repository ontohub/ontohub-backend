# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Repository::AddUrlMappingMutation do
  let!(:user) { create :user }
  let(:repository) { create :repository_compound, owner: user }
  let(:url_mapping_blueprint) { attributes_for(:url_mapping) }

  let(:context) { {current_user: current_user} }

  let(:variables) do
    {'repositoryId' => repository.to_param,
     'source' => url_mapping_blueprint[:source],
     'target' => url_mapping_blueprint[:target]}
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
    mutation ($repositoryId: ID!, $source: String!, $target: String!) {
      addUrlMapping(repositoryId: $repositoryId, source: $source, target: $target) {
        id
        number
        source
        target
      }
    }
    QUERY
  end

  subject { result }

  context 'User is signed in' do
    let(:current_user) { user }
    it 'returns the sequence number' do
      expect(subject['data']['addUrlMapping']['number']).to eq(1)
    end

    it 'returns the source string' do
      expect(subject['data']['addUrlMapping']['source']).
        to eq(url_mapping_blueprint[:source])
    end

    it 'returns the target string' do
      expect(subject['data']['addUrlMapping']['target']).
        to eq(url_mapping_blueprint[:target])
    end
  end

  context 'Unable to see the repository' do
    let!(:repository) { create :repository_compound, :private }
    let(:context) { {} }

    it 'returns an error' do
      expect(subject['data']['addUrlMapping']).to be(nil)
      expect(subject['errors']).
        to include(include('message' => 'resource not found'))
    end
  end

  context 'User not signed in' do
    let(:current_user) { nil }
    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' => "You're not authorized to do this"))
    end

    it 'returns no data' do
      expect(subject['data']['addUrlMapping']).to be(nil)
    end
  end
end
