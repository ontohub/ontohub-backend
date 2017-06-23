# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::Users::UnlocksController do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  let!(:user) { create(:user) }
  let!(:token) { user.lock_access! }

  describe 'POST create', type: :mailer, no_transaction: true do
    before do
      post :create, params: {data: {attributes: {email: user.email}}}
    end
    it { expect(response).to have_http_status(:created) }
    it { |example| expect([example, response]).to comply_with_api }

    context 'unlock instructions email' do
      it 'sends an instructions email' do
        expect(UsersMailer.deliveries.size).to eq(1)
      end

      it 'is has the correct recipient' do
        expect(last_email.to).to match_array([user.email])
      end

      it 'is has the correct subject' do
        expect(last_email.subject).to eq('Unlock instructions')
      end

      it 'includes the name' do
        expect(last_email.body.encoded).to include(user.display_name)
      end

      it 'includes the unlock token' do
        expect(last_email.body.encoded).
          to match(/^Your unlock token is: \S+\s*$/)
      end

      it 'includes a unlock link' do
        # rubocop:disable Metrics/LineLength
        link = %r{<a href="http://example.test/users/unlock\?unlock_token=[^"]+">Unlock my account</a>}
        # rubocop:enable Metrics/LineLength
        expect(last_email.body.encoded).to match(link)
      end
    end
  end

  describe 'PATCH update' do
    context 'successful' do
      before do
        patch :update, params: {unlock_token: token}
      end

      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_api }
      it 'unlocks the user' do
        expect(user.reload.access_locked?).to be(false)
      end
    end

    context 'bad token' do
      before do
        patch :update,
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
