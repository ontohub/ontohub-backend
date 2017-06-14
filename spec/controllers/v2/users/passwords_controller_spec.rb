# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::Users::PasswordsController do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  let(:user) { create(:user) }

  describe 'GET edit' do
    context 'is a no-op' do
      before do
        get :edit
      end
      it { expect(response).to have_http_status(:no_content) }
      it { expect(response.body).to be_empty }
    end
  end

  describe 'POST create' do
    before do
      post :create, params: {data: {attributes: {email: user.email}}}
    end
    it { expect(response).to have_http_status(:created) }
    it { |example| expect([example, response]).to comply_with_api }
  end

  describe 'PATCH update' do
    let(:old_password) { user.password }
    let(:new_password) { "new-#{user.password}" }

    before do
      token = user.send_reset_password_instructions
      patch :update, params: {data: {attributes: {reset_password_token: token,
                                                  password: new_password}}}
    end
    it { expect(response).to have_http_status(:ok) }
    it { |example| expect([example, response]).to comply_with_api }
    it 'makes it impossible to sign in with the old password' do
      expect(user.reload.valid_password?(old_password)).to be(false)
    end
    it 'makes it possible to sign in with the new password' do
      expect(user.reload.valid_password?(new_password)).to be(true)
    end
  end
end
