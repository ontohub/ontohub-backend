# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/confirmation_email'

RSpec.describe V2::Users::AccountController do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  let(:user) { build(:user) }
  let(:attributes) do
    {name: user.name,
     display_name: user.display_name,
     email: user.email,
     password: '1234567890',
     captcha: 'my-captcha-token'}
  end
  let!(:existing_user) { create(:user) }
  let!(:existing_organization) { create(:organization) }

  before { existing_user.confirm }

  describe 'POST create' do
    context 'successful', type: :mailer, no_transaction: true do
      before do
        queue_adapter.performed_jobs = []
        perform_enqueued_jobs do
          post :create, params: {data: {attributes: attributes}}
        end
      end
      it { expect(response).to have_http_status(:created) }
      it { |example| expect([example, response]).to comply_with_api }
      it_behaves_like 'a confirmation email sender'
    end

    context 'failing with invalid data', type: :mailer, no_transaction: true do
      before do
        post :create,
          params: {data: {name: existing_organization.slug,
                          email: 'not-an-email',
                          password: 'too long' * 129}}
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it do |example|
        expect([example, response]).to comply_with_api('validation_error')
      end
      it 'does not send an email' do
        expect(UsersMailer.deliveries).to be_empty
      end
      # captcha validation is disabled in the tests
      %i(name email password).each do |attribute|
        it "has an error at #{attribute}" do
          expect(validation_error_at?(attribute)).to be(true)
        end
      end
    end
  end

  describe 'PATCH update' do
    let(:new_attributes) do
      {display_name: "changed-#{existing_user.display_name}",
       email: "changed-#{existing_user.email}",
       password: "changed-#{existing_user.password}",
       current_password: existing_user.password}
    end

    context 'signed in' do
      before { set_token_header(existing_user) }

      context 'successful', type: :mailer, no_transaction: true do
        before do
          queue_adapter.performed_jobs = []
          perform_enqueued_jobs do
            patch :update, params: {data: {attributes: new_attributes}}
          end
        end
        it { expect(response).to have_http_status(:ok) }
        %i(display_name encrypted_password).each do |attribute|
          it "updates the #{attribute}" do
            # rubocop:disable Lint/AmbiguousBlockAssociation
            expect { existing_user.reload }.
              to change { existing_user.send(attribute) }
            # rubocop:enable Lint/AmbiguousBlockAssociation
          end
        end

        it 'updates the unconfirmed_email' do
          # rubocop:disable Lint/AmbiguousBlockAssociation
          expect { existing_user.reload }.
            to change { existing_user.unconfirmed_email }
          # rubocop:enable Lint/AmbiguousBlockAssociation
        end

        it 'sends a confirmation email and two notification emails' do
          expect(performed_jobs.size).to eq(3)
          expect(UsersMailer.deliveries.size).to eq(3)
        end

        context 'email changed notification email' do
          let(:email) { emails[0] }

          it 'has the correct recipient' do
            expect(email.to).to match_array([existing_user.email])
          end

          it 'has the correct subject' do
            expect(email.subject).to eq('Email Changed')
          end

          it 'includes the name' do
            expect(email.body.encoded).to include(existing_user.display_name)
          end

          it 'includes the unconfirmed email' do
            expect(email.body.encoded).
              to include(existing_user.reload.unconfirmed_email)
          end
        end

        context 'password changed notification email' do
          let(:email) { emails[1] }

          it 'has the correct recipient' do
            expect(email.to).to match_array([existing_user.email])
          end

          it 'has the correct subject' do
            expect(email.subject).to eq('Password Changed')
          end

          it 'includes the name' do
            expect(email.body.encoded).to include(existing_user.display_name)
          end

          it 'includes a notice about the changed password' do
            expect(email.body.encoded).to include('password has been changed')
          end
        end

        context 'confirmation mail' do
          let(:email) { emails[2] }

          it 'has the correct recipient' do
            expect(email.to).
              to match_array([existing_user.reload.unconfirmed_email])
          end

          it 'has the correct subject' do
            expect(email.subject).to eq('Confirmation instructions')
          end

          it 'includes the name' do
            expect(email.body.encoded).to include(existing_user.display_name)
          end

          it 'includes the confirmation token' do
            expect(email.body.encoded).
              to include(existing_user.reload.confirmation_token)
          end

          it 'includes a confirmation link' do
            persisted_user = User.find(email: existing_user.email)
            token = persisted_user.confirmation_token
            # rubocop:disable Metrics/LineLength
            link = %(<a href="http://example.test/users/confirmation?confirmation_token=#{token}">Confirm my account</a>)
            # rubocop:enable Metrics/LineLength
            expect(email.body.encoded).to include(link)
          end
        end
      end

      context 'failing', type: :mailer, no_transaction: true do
        context 'with a bad current_password' do
          before do
            patch :update, params: {data: {attributes:
              new_attributes.merge(current_password:
                "bad-#{existing_user.password}")}}
          end
          it { expect(response).to have_http_status(:unprocessable_entity) }
          it do |example|
            expect([example, response]).to comply_with_api('validation_error')
          end
          it 'does not send an email' do
            expect(UsersMailer.deliveries).to be_empty
          end
          %i(current_password).each do |attribute|
            it "has an error at #{attribute}" do
              expect(validation_error_at?(attribute)).to be(true)
            end
          end
          it 'current_password has the correct error message' do
            expect(validation_errors_at(:current_password)).
              to include('invalid')
          end
          %i(email display_name encrypted_password).each do |attribute|
            it "does not update the #{attribute}" do
              # rubocop:disable Lint/AmbiguousBlockAssociation
              expect { existing_user.reload }.
                not_to change { existing_user.send(attribute) }
              # rubocop:enable Lint/AmbiguousBlockAssociation
            end
          end
        end

        context 'with invalid data' do
          before do
            patch :update,
              params: {data: {attributes: new_attributes.
                merge(display_name: 'a' * 101,
                      email: 'not-an-email',
                      password: 'too short')}}
          end

          it { expect(response).to have_http_status(:unprocessable_entity) }
          it do |example|
            expect([example, response]).to comply_with_api('validation_error')
          end
          # captcha validation is disabled in the tests
          %i(display_name email password).each do |attribute|
            it "has an error at #{attribute}" do
              expect(validation_error_at?(attribute)).to be(true)
            end
          end
        end
      end
    end

    context 'not signed in' do
      before do
        patch :update, params: {data: {attributes: new_attributes}}
      end
      it { expect(response).to have_http_status(:unauthorized) }
      it 'has the correct response body' do
        expect(response.body).
          to eq('You need to sign in or sign up before continuing.')
      end
    end
  end

  describe 'DELETE destroy' do
    context 'signed in' do
      before do
        set_token_header(existing_user)
        delete :destroy
      end
      it { expect(response).to have_http_status(:no_content) }
      it { expect(response.body.strip).to be_empty }
    end

    context 'not signed in' do
      before { delete :destroy }
      it { expect(response).to have_http_status(:unauthorized) }
      it 'has the correct response body' do
        expect(response.body).
          to eq('You need to sign in or sign up before continuing.')
      end
    end
  end
end
