# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/resend_unlock_account_email'

RSpec.describe V2::Users::UnlockController do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  let!(:user) { create(:user) }
  let!(:token) { user.lock_access! }

  describe 'POST resend_unlocking_email', type: :mailer, no_transaction: true do
    before do
      post :resend_unlocking_email,
        params: {data: {attributes: {email: user.email}}}
    end
    it { expect(response).to have_http_status(:created) }
    it { |example| expect([example, response]).to comply_with_api }
    it_behaves_like 'an unlock account email sender'
  end

  describe 'PATCH unlock_account' do
    context 'successful' do
      before do
        patch :unlock_account, params: {unlock_token: token}
      end

      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_api }
      it 'unlocks the user' do
        expect(user.reload.access_locked?).to be(false)
      end
    end

    context 'bad token' do
      before do
        patch :unlock_account,
          params: {unlock_token: "bad-#{token}"}
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it do |example|
        expect([example, response]).to comply_with_api('validation_error')
      end
      it 'does not unlock the user' do
        expect(user.access_locked?).to be(true)
      end
    end
  end
end
