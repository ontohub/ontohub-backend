# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::Users::RegistrationsController do
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

  describe 'POST create' do
    context 'successful' do
      before do
        post :create, params: {data: {attributes: attributes}}
      end
      it { expect(response).to have_http_status(:created) }
      it { |example| expect([example, response]).to comply_with_api }
    end

    context 'failing with invalid data' do
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

      context 'successful' do
        before do
          patch :update, params: {data: {attributes: new_attributes}}
        end
        it { expect(response).to have_http_status(:ok) }
        %i(email display_name encrypted_password).each do |attribute|
          it "updates the #{attribute}" do
            expect { existing_user.reload }.
              to change { existing_user.send(attribute) }
          end
        end
      end

      context 'failing' do
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
          %i(current_password).each do |attribute|
            it "has an error at #{attribute}" do
              expect(validation_error_at?(attribute)).to be(true)
            end
          end
          it 'current_password has the correct error message' do
            expect(validation_errors_at(:current_password)).to include('invalid')
          end
          %i(email display_name encrypted_password).each do |attribute|
            it "does not update the #{attribute}" do
              expect { existing_user.reload }.
                not_to change { existing_user.send(attribute) }
            end
          end
        end

        context 'with invalid data' do
          before do
            patch :update,
              params: {data: {attributes: new_attributes.
                merge(display_name: 'a'*101,
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
