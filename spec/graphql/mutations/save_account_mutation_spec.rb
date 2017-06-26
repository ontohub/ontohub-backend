# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'saveAccount mutation' do
  let!(:user) { create :user, password: 'changemenow' }
  let(:user_data) do
    {
      'displayName' => 'Foobar',
      'email' => 'foo@bar.com',
      'password' => 'foobarchangeme',
    }
  end

  let(:context) { {current_user: user} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation SaveAccount($data: UserChangeset!, $password: String!) {
      saveAccount(data: $data, password: $password) {
        id
        displayName
        email
        unconfirmedEmail
      }
    }
    QUERY
  end

  context 'Correct password' do
    let(:variables) { {'data' => user_data, 'password' => 'changemenow'} }
    subject { result }

    it 'returns the new account fields' do
      expect(subject['data']['saveAccount']).to include(
        'id' => user.slug,
        'displayName' => user_data['displayName'],
        'email' => user.email,
        'unconfirmedEmail' => user_data['email']
      )
    end
  end

  context 'Incorrect password' do
    let(:variables) { {'data' => user_data, 'password' => 'changemeow'} }
    subject { result }

    it 'returns the old account fields' do
      expect(subject['data']['saveAccount']).to include(
        'id' => user.slug,
        'displayName' => user.display_name,
        'email' => user.email
      )
    end
  end
end
