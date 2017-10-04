# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Account::UnlockAccountMutation,
               stub_abstract_devise_mutation: true do
  let!(:user) { create :user }
  let!(:token) { user.lock_access! }

  let(:context) { {} }
  let(:variables) { {'token' => token} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation UnlockAccount($token: String!) {
      unlockAccount(token: $token) {
        jwt
        me {
          id
        }
      }
    }
    QUERY
  end

  subject { result }
  before { subject }

  context 'valid token' do
    it 'returns the JWT' do
      expect(subject['data']['unlockAccount']['jwt']).not_to be_blank
    end

    it 'returns the user' do
      expect(subject['data']['unlockAccount']['me']['id']).to eq(user.to_param)
    end

    it 'unlocks the user' do
      expect(user.reload.access_locked?).to be(false)
    end
  end

  context 'invalid token' do
    let(:variables) { {'token' => "bad-#{token}"} }

    it 'returns no data' do
      expect(subject['data']['unlockAccount']).to be(nil)
    end

    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' => 'Invalid unlock token.'))
    end

    it 'does not unlock the user' do
      expect(user.access_locked?).to be(true)
    end
  end
end
