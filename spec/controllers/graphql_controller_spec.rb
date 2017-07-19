# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GraphqlController do
  before do
    # Make rails load the Version model
    Version # rubocop:disable Lint/Void
    stub_const('Version::VERSION', '0.0.0-12-gabcdefg')
  end
  let!(:user) { create :user }

  let(:version_query) do
    <<-QUERY
    query VersionQuery {
      version {
        full
      }
    }
    QUERY
  end
  let(:user_query) do
    <<-QUERY
    query UserQuery($id: ID!) {
      organizationalUnit(id: $id) {
        displayName
      }
    }
    QUERY
  end

  let(:result) { JSON.parse(response.body) }

  before do
    post :execute,
          params: params
  end

  context 'single query' do
    let(:params) do
      {query: user_query,
       variables: {'id' => user.to_param}}
    end

    it { expect(response).to have_http_status(:ok) }
    it 'returns the queried user data' do
      display_name = result.dig('data', 'organizationalUnit', 'displayName')
      expect(display_name).to eq(user.display_name)
    end
  end

  context 'multiplexed queries' do
    let(:params) do
      {_json: [{query: user_query,
                variables: {'id' => user.to_param}},
               {query: version_query}],
       graphql: true}
    end

    it { expect(response).to have_http_status(:ok) }
    it 'returns the queried user data' do
      display_name = result.dig(0, 'data', 'organizationalUnit', 'displayName')
      expect(display_name).to eq(user.display_name)
    end
    it 'returns the queried version data' do
      full_version = result.dig(1, 'data', 'version', 'full')
      expect(full_version).to eq(Version::VERSION)
    end
  end
end
