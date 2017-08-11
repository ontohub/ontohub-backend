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
            params: {user: {
              name: user.to_param,
              password: "#{user.password}bad",
            }},
            format: :json
        end
        it { expect(response).to have_http_status(:unauthorized) }
        it do |example|
          expect([example, response]).
            to comply_with_api('users/sessions/post_create_fail', false)
        end
        it { expect(response_hash['errors']).not_to be_empty }
      end

      context 'incorrect username' do
        before do
          post :create,
            params: {user: {
              name: "#{user.to_param}bad",
              password: user.password,
            }},
            format: :json
        end
        it { expect(response).to have_http_status(:unauthorized) }
        it do |example|
          expect([example, response]).
            to comply_with_api('users/sessions/post_create_fail', false)
        end
        it { expect(response_hash['errors']).not_to be_empty }
      end

      context 'locking after failed sign in attempts', type: :mailer,
                                                       no_transaction: true do
        let(:original_unlock_in) { 10.minutes }
        before { User.unlock_in = original_unlock_in }
        after { User.unlock_in = original_unlock_in }

        context 'first failed attempt' do
          before do
            User.maximum_attempts = 2
            queue_adapter.performed_jobs = []
            perform_enqueued_jobs do
              post :create,
                params: {user: {
                  name: user.to_param,
                  password: "bad-#{user.password}",
                }},
                format: :json
            end
          end

          it 'does not lock the user' do
            expect(user.reload.access_locked?).to be(false)
          end

          it 'does not send an email' do
            assert_performed_jobs 0
          end
        end

        context 'last failed attempt' do
          before do
            User.maximum_attempts = 1
            queue_adapter.performed_jobs = []
            perform_enqueued_jobs do
              post :create,
                params: {user: {
                  name: user.to_param,
                  password: "bad-#{user.password}",
                }},
                format: :json
            end
          end

          it 'locks the user' do
            expect(user.reload.access_locked?).to be(true)
          end

          context 'unlock instructions email' do
            it 'sends an instructions email' do
              assert_performed_jobs 1
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

        context 'already locked' do
          before { user.lock_access! }
          context 'with timeout not yet reached' do
            before do
              User.unlock_in = 10.minutes
              post :create,
                params: {user: {name: user.to_param, password: user.password}},
                format: :json
            end

            it { expect(response).to have_http_status(:unauthorized) }
            it do |example|
              expect([example, response]).
                to comply_with_api('users/sessions/post_create_fail', false)
            end
            it { expect(response_hash['errors']).not_to be_empty }
          end

          context 'with timeout reached' do
            before do
              User.unlock_in = -10.minutes
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
        end
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
        it { expect(response_hash['errors']).not_to be_empty }
      end
    end

    context 'empty request' do
      before do
        post :create, format: :json
      end
      it { expect(response).to have_http_status(:unauthorized) }
      it { expect(response_hash['errors']).not_to be_empty }
    end
  end
end
