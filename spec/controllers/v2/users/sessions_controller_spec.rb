# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::Users::SessionsController do
  context 'login' do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
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
        it { expect(JSON.parse(response.body)['data']['attributes']['token']).
             not_to be_empty }

      end

      context 'incorrect' do
        before do
          post :create,
          params: {user: {name: user.name, password: user.password + 'foo'}},
          format: :json
        end
        it { expect(response).to have_http_status(:unauthorized) }
        it { expect(JSON.parse(response.body)['error']).not_to be_empty }
      end
    end

    # context 'with token' do
    # end
  end
end
