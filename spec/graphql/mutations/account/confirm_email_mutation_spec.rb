# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Account::ConfirmEmailMutation,
               stub_abstract_devise_mutation: true do
  let!(:user) { create :user }

  let(:context) { {} }
  let(:variables) { {} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation ConfirmEmail($token: String!) {
      confirmEmail(token: $token) {
        jwt
        me {
          id
        }
      }
    }
    QUERY
  end

  subject { result }

  context 'valid token' do
    let(:variables) { {'token' => user.confirmation_token} }

    it 'returns the JWT' do
      expect(subject['data']['confirmEmail']['jwt']).not_to be_blank
    end

    it 'returns the user' do
      expect(subject['data']['confirmEmail']['me']['id']).to eq(user.to_param)
    end
  end

  context 'invalid token' do
    let(:variables) { {'token' => "bad-#{user.confirmation_token}"} }

    it 'returns no data' do
      expect(subject['data']['confirmEmail']).to be(nil)
    end

    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' => 'Invalid confirmation token.'))
    end
  end
end
