# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/resend_password_reset_email'
require 'shared_examples/password_has_been_reset_email'

RSpec.describe V2::Users::PasswordsController do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  let!(:user) { create(:user) }

  describe 'GET edit' do
    context 'is a no-op' do
      before do
        get :edit
      end
      it { expect(response).to have_http_status(:no_content) }
      it { expect(response.body).to be_empty }
    end
  end

  describe 'POST resend_password_recovery_email',
    type: :mailer, no_transaction: true do
    before do
      post :resend_password_recovery_email,
        params: {data: {attributes: {email: user.email}}}
    end
    it { expect(response).to have_http_status(:created) }
    it { |example| expect([example, response]).to comply_with_api }
    it_behaves_like 'a password reset email sender'
  end

  describe 'PATCH recover_password', type: :mailer, no_transaction: true do
    let(:old_password) { user.password }
    let(:new_password) { "new-#{user.password}" }

    context 'successful' do
      before do
        token = user.send_reset_password_instructions
        UsersMailer.deliveries.clear
        patch :recover_password,
          params: {data: {attributes: {reset_password_token: token,
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
      it_behaves_like 'a password has been reset email sender'
    end

    context 'failing with a bad token' do
      before do
        UsersMailer.deliveries.clear
        token = "bad-#{user.send_reset_password_instructions}"
        patch :recover_password,
          params: {data: {attributes: {reset_password_token: token,
                                       password: new_password}}}
      end
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it do |example|
        expect([example, response]).to comply_with_api('validation_error')
      end
    end
  end
end
