# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GraphqlController do
  before do
    # Make rails load the Version model
    Version # rubocop:disable Lint/Void
    stub_const('Version::VERSION', '0.0.0-12-gabcdefg')
  end

  context 'not signed in' do
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
        display_name =
          result.dig(0, 'data', 'organizationalUnit', 'displayName')
        expect(display_name).to eq(user.display_name)
      end
      it 'returns the queried version data' do
        full_version = result.dig(1, 'data', 'version', 'full')
        expect(full_version).to eq(Version::VERSION)
      end
    end
  end

  context 'signed in as a user' do
    let(:me_query) do
      <<-QUERY
      query {
        me {
          id
        }
      }
      QUERY
    end

    let(:params) do
      {query: me_query}
    end

    let(:result) { JSON.parse(response.body) }

    context 'using the devise helper' do
      create_user_and_sign_in
      before do
        post :execute,
          params: params
      end

      it { expect(response).to have_http_status(:ok) }
      it 'returns the queried user data' do
        # There is only one user created by create_user_and_sign_in
        user = User.first
        expect(result.dig('data', 'me', 'id')).to eq(user.to_param)
      end
    end

    context 'setting the token explicitly' do
      context 'with a valid token' do
        let!(:user) { create_user_and_set_token_header }

        before do
          post :execute,
            params: params
        end

        it { expect(response).to have_http_status(:ok) }
        it 'returns the queried user data' do
          expect(result.dig('data', 'me', 'id')).to eq(user.to_param)
        end
      end

      context 'with an invalid token' do
        before do
          request.env['HTTP_AUTHORIZATION'] = 'Bearer ThisIsAnInvalidToken'
          post :execute,
            params: params
        end

        it { expect(response).to have_http_status(:ok) }
        it 'returns no user data' do
          expect(result.dig('data', 'me')).to be(nil)
        end
      end
    end
  end

  context 'signed in via API key' do
    let(:query) do
      <<-QUERY
        query Repository($id: ID!) {
          repository(id: $id) {
            id
          }
        }
      QUERY
    end

    let(:params) do
      {query: query,
       variables: {'id' => repository.to_param}}
    end

    let(:result) { JSON.parse(response.body) }

    let(:raw_key) { api_key_data[:raw] }
    let(:api_key) { api_key_data[:api_key] }

    let!(:repository) { create(:repository, :private) }

    context 'with a valid GitShellApiKey' do
      let!(:api_key_data) { create_api_key_and_set_header(GitShellApiKey) }
      before do
        post :execute, params: params
      end

      it { expect(response).to have_http_status(:ok) }
      it 'returns the queried repository data' do
        expect(result).to match('data' => {'repository' => nil})
      end
    end

    context 'with a valid HetsApiKey' do
      let!(:api_key_data) { create_api_key_and_set_header(HetsApiKey) }
      before do
        post :execute, params: params
      end

      it { expect(response).to have_http_status(:ok) }
      it 'returns the queried repository data' do
        expect(result).
          to match('data' => {'repository' => {'id' => repository.to_param}})
      end
    end

    context 'with an invalid API key' do
      before do
        request.env['HTTP_AUTHORIZATION'] = 'ApiKey ThisIsAnInvalidKey'
        post :execute, params: params
      end

      it { expect(response).to have_http_status(:ok) }
      it 'returns no repository data' do
        expect(result).to match('data' => {'repository' => nil})
      end
    end
  end
end
