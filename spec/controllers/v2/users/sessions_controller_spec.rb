# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::Users::SessionsController do
  context 'login' do
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end
    let!(:user) { create :user }

    context 'with credentials' do
      context 'correct' do
        before do
          post :create,
          params: {user: {name: user.name, password: user.password}},
          format: :json
        end
        it { expect(response).to have_http_status(:created) }
        it do
          expect(response_data['attributes']['token']).
            not_to be_empty
        end
      end

      context 'incorrect' do
        before do
          post :create,
          params: {user: {name: user.name, password: user.password + 'foo'}},
          format: :json
        end
        it { expect(response).to have_http_status(:unauthorized) }
        it { expect(response_hash['error']).not_to be_empty }
      end
    end

    context 'with token' do
      context 'correct' do
        before do
          payload = {user_id: user.to_param}
          token = JWTWrapper.encode(payload)
          request.env['HTTP_AUTHORIZATION'] = "Bearer #{token}"
          post :create, format: :json
        end
        it { expect(response).to have_http_status(:created) }
        it do
          expect(response_data['attributes']['token']).
            not_to be_empty
        end
      end

      context 'incorrect' do
        before do
          request.env['HTTP_AUTHORIZATION'] = 'Bearer foobar'
          post :create,
          format: :json
        end
        it { expect(response).to have_http_status(:unauthorized) }
        it { expect(response_hash['error']).not_to be_empty }
      end
    end
  end
end
