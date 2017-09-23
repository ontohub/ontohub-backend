# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rest::VersionController do
  describe 'action: show' do
    before do
      Version # rubocop:disable Lint/Void
      stub_const('Version::VERSION', '0.0.0-12-gabcdefg')
    end

    context 'json' do
      before { get :show }
      it { expect(response).to have_http_status(:ok) }
      it { |example| expect([example, response]).to comply_with_rest_api }
    end

    context 'Accept header' do
      context 'only with json' do
        before do
          request.headers['Accept'] = 'application/json'
          get :show
        end

        it { expect(response).to have_http_status(:ok) }
        it 'does not respond with the plain text version' do
          expect(response_data.dig('version', 'full')).to eq(Version::VERSION)
        end
      end

      context 'only with plain' do
        before do
          request.headers['Accept'] = 'text/plain'
          get :show
        end

        it { expect(response).to have_http_status(:ok) }
        it 'responds with the plain text version' do
          expect(response.body).to eq(Version::VERSION)
        end
      end

      context 'with a quality parameter and a weaker alternative' do
        before do
          request.headers['Accept'] = 'application/json; q=0.1, text/plain; q=1'
          get :show
        end

        it { expect(response).to have_http_status(:ok) }
        it 'responds with the plain text version' do
          expect(response.body).to eq(Version::VERSION)
        end
      end

      context 'with a quality parameter and a weaker alternative in reverse '\
        'order' do
        before do
          request.headers['Accept'] = 'text/plain; q=1, application/json; q=0.1'
          get :show
        end

        it { expect(response).to have_http_status(:ok) }
        it 'responds with the plain text version' do
          expect(response.body).to eq(Version::VERSION)
        end
      end

      context 'with a quality parameter and a stronger alternative' do
        before do
          request.headers['Accept'] = 'application/json; q=1, text/plain; q=0.1'
          get :show
        end

        it { expect(response).to have_http_status(:ok) }
        it 'does not respond with the plain text version' do
          expect(response_data.dig('version', 'full')).to eq(Version::VERSION)
        end
      end
    end
  end
end
