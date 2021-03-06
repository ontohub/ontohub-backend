# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Repository::RemoveUrlMappingMutation do
  let!(:user) { create :user }
  let(:repository) { create(:repository_compound) }
  let(:url_mapping) { create(:url_mapping, repository_id: repository.id) }
  before do
    repository.add_member(user, 'admin')
  end

  let(:context) { {current_user: current_user} }

  let(:url_mapping_id) { url_mapping.to_param }
  let(:repository_id) { repository.to_param }
  let(:variables) do
    {'urlMappingId' => url_mapping_id,
     'repositoryId' => repository_id}
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
    mutation ($repositoryId: ID!, $urlMappingId: ID!) {
      removeUrlMapping(repositoryId: $repositoryId, urlMappingId: $urlMappingId)
    }
    QUERY
  end

  subject { result }

  shared_examples 'failing to delete' do
    it 'deletion of Url Mapping failed' do
      expect(subject['data']['removeUrlMapping']).
        to eq(expectation_response_matcher)
    end

    it 'does not remove the database entry' do
      subject
      expect(UrlMapping.first(id: url_mapping.id)).not_to be(nil)
    end

    it 'returns an error message when deletion failed' do
      expect(subject['errors']).
        to include(include('message' => error_message))
    end
  end

  context 'User is signed in' do
    let(:current_user) { user }
    context 'repository ID is valid' do
      context 'when the URL mapping exists' do
        it 'deletes Url Mapping' do
          expect(subject['data']['removeUrlMapping']).
            to eq(true)
        end

        it 'removes the mapping from the database' do
          subject
          expect(UrlMapping.first(id: url_mapping.id)).
            to be(nil)
        end
      end
      context 'When the object does not exist' do
        it_behaves_like 'failing to delete' do
          let(:url_mapping_id) { 0 }
          let(:expectation_response_matcher) { false }
          let(:error_message) { 'resource not found' }
        end
      end
    end
    context 'Repository ID is not vaild' do
      let(:repository_id) { "bad-#{repository.to_param}" }
      context 'When the URL mapping exists' do
        it_behaves_like 'failing to delete' do
          let(:expectation_response_matcher) { nil }
          let(:error_message) { 'resource not found' }
        end
      end
      context 'When the object does not exist' do
        it_behaves_like 'failing to delete' do
          let(:url_mapping_id) { 0 }
          let(:expectation_response_matcher) { nil }
          let(:error_message) { 'resource not found' }
        end
      end
    end
  end

  context 'Unable to see the repository' do
    let!(:repository) { create :repository_compound, :private }
    let(:context) { {} }

    it 'returns an error' do
      expect(subject['data']['removeUrlMapping']).to be(nil)
      expect(subject['errors']).
        to include(include('message' => 'resource not found'))
    end
  end

  context 'User not signed in' do
    let(:current_user) { nil }
    context 'Repository ID is valid' do
      context 'When the URL mapping exists' do
        it_behaves_like 'failing to delete' do
          let(:expectation_response_matcher) { nil }
          let(:error_message) { "You're not authorized to do this" }
        end
      end
      context 'When the object does not exists' do
        it_behaves_like 'failing to delete' do
          let(:url_mapping_id) { 0 }
          let(:expectation_response_matcher) { nil }
          let(:error_message) { "You're not authorized to do this" }
        end
      end
    end
    context 'Repository ID is not valid' do
      let(:repository_id) { "bad-#{repository.to_param}" }
      context 'When the URL mapping exists' do
        it_behaves_like 'failing to delete' do
          let(:expectation_response_matcher) { nil }
          let(:error_message) { 'resource not found' }
        end
      end
      context 'When the object does not exists' do
        it_behaves_like 'failing to delete' do
          let(:url_mapping_id) { 0 }
          let(:expectation_response_matcher) { nil }
          let(:error_message) { 'resource not found' }
        end
      end
    end
  end
end
