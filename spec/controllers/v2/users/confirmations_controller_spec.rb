# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/confirmation_email'

RSpec.describe V2::Users::ConfirmationController do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  let!(:user) { create(:user) }

  describe 'PATCH confirm_email_address' do
    context 'successful' do
      before do
        patch :confirm_email_address,
          params: {confirmation_token: user.confirmation_token}
      end

      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_api }
      it 'confirms the user' do
        expect(user.reload.confirmed?).to be(true)
      end
    end

    context 'bad token' do
      before do
        patch :confirm_email_address,
          params: {confirmation_token: "bad-#{user.confirmation_token}"}
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it do |example|
        expect([example, response]).to comply_with_api('validation_error')
      end
      it 'does not confirm the user' do
        expect(user.reload.confirmed?).to be(false)
      end
    end
  end

  describe 'POST resend_confirmation_email',
    type: :mailer, no_transaction: true do
    before do
      UsersMailer.deliveries.clear
      post :resend_confirmation_email,
        params: {data: {attributes: {email: user.email}}}
    end
    it { expect(response).to have_http_status(:created) }
    it { |example| expect([example, response]).to comply_with_api }
    it_behaves_like 'a confirmation email sender'
  end
end
