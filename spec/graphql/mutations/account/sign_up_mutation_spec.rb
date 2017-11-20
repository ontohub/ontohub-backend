# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/confirmation_email'

RSpec.describe Mutations::Account::SignUpMutation,
  type: :mailer, no_transaction: true, stub_abstract_devise_mutation: true do
  let(:user_data) do
    user = build(:user)
    user.send(:set_slug)
    user.values.slice(:slug, :display_name, :email, :password).
      transform_keys { |k| k == :slug ? 'username' : k.to_s.camelize(:lower) }.
      # The password is only an attr_accessor, hence not in the +values+:
      merge('password' => user.password)
  end
  let(:captcha) { 'not really used in the test environment' }
  let(:context) { {} }
  let(:variables) { {'user' => user_data, 'captcha' => captcha} }

  let(:result) do
    perform_enqueued_jobs do
      OntohubBackendSchema.execute(
        query_string,
        context: context,
        variables: variables
      )
    end
  end

  let(:query_string) do
    <<-QUERY
    mutation SignUp($user: NewUser!, $captcha: String!) {
      signUp(user: $user, captcha: $captcha) {
        jwt
        me {
          id
        }
      }
    }
    QUERY
  end

  subject { result }

  context 'successful' do
    let(:user) { User.first(slug: user_data['username']) }

    context 'with immediate access' do
      before { subject }

      it 'returns the JWT' do
        expect(subject['data']['signUp']['jwt']).not_to be_blank
      end

      it 'saves and returns the user' do
        expect(subject['data']['signUp']['me']['id']).to eq(user.to_param)
      end
      it_behaves_like 'a confirmation email sender'
    end

    context 'without immediate access' do
      let!(:original_unconfirmed_access) { Devise.allow_unconfirmed_access_for }
      before do
        Devise.allow_unconfirmed_access_for = -1.days
        subject
      end
      after do
        Devise.allow_unconfirmed_access_for = original_unconfirmed_access
      end

      it 'returns no session data' do
        expect(subject['data']['signUp']).to be(nil)
      end

      it 'returns no error' do
        expect(subject['errors']).to be(nil)
      end

      it_behaves_like 'a confirmation email sender'
    end
  end

  context 'unsuccessful' do
    context 'name is not available' do
      before do
        create :user, name: user_data['username']
      end

      it 'returns no data' do
        expect(subject['data']['signUp']).to be(nil)
      end

      it 'returns an error' do
        expect(subject['errors']).
          to include(include('message' => 'name is already taken'))
      end
    end

    context 'invalid data' do
      let(:user_data) do
        {'username' => 'a', 'email' => 'e', 'password' => 'p'}
      end
      it 'returns no data' do
        expect(subject['data']['signUp']).to be(nil)
      end

      ['password must be between',
       'email is invalid',
       'name is invalid',
       'name is too short or too long',
       'name must start and end with'].each do |error|
        it %(returns the error "#{error}") do
          expect(subject['errors']).
            to include(include('message' => include(error)))
        end
      end
    end

    context 'already signed in' do
      let(:context) { {current_user: create(:user)} }

      it 'returns no data' do
        expect(subject['data']['signUp']).to be(nil)
      end

      it 'returns an error' do
        expect(subject['errors']).
          to include(include('message' => "You're not authorized to do this"))
      end
    end
  end
end
