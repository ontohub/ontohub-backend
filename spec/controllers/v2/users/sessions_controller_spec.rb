# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::Users::SessionsController do
  context 'login' do
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
    end
    let!(:user) { create :user }

    context 'POST create' do
      context 'correct' do
        before do
          post :create,
            params: {user: {name: user.to_param, password: user.password}},
            format: :json
        end
        it { expect(response).to have_http_status(:created) }
        it { |example| expect([example, response]).to comply_with_api }
        it do
          expect(response_data['attributes']['token']).not_to be_empty
        end
      end

      context 'incorrect password' do
        before do
          post :create,
            params: {user: {name: user.to_param, password: user.password + 'bad'}},
            format: :json
        end
        it { expect(response).to have_http_status(:unauthorized) }
        it do |example|
          expect([example, response]).
            to comply_with_api('users/sessions/post_create_fail', false)
        end
        it { expect(response_hash['error']).not_to be_empty }
      end

      context 'incorrect username' do
        before do
          post :create,
            params: {user: {name: user.to_param + 'bad', password: user.password}},
            format: :json
        end
        it { expect(response).to have_http_status(:unauthorized) }
        it do |example|
          expect([example, response]).
            to comply_with_api('users/sessions/post_create_fail', false)
        end
        it { expect(response_hash['error']).not_to be_empty }
      end
    end

    context 'with token' do
      context 'correct' do
        before do
          set_token_header(user)
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

    context 'empty request' do
      before do
        post :create, format: :json
      end
      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(response_hash['error']).not_to be_empty }
    end
  end
end
