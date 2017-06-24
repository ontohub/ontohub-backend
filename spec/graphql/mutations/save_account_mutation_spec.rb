# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'saveAccount mutation' do
  let!(:user) { create :user }
  let(:user_data) do
    {
      'displayName' => 'Foobar',
      'email' => 'foo@bar.com',
      'password' => 'foobarchangeme'
    }
  end

  let(:context) { {current_user: user} }
  let(:variables) { {'data' => user_data} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation SaveAccount($data: UserChangeset!) {
      saveAccount(data: $data) {
        id
        displayName
        email
      }
    }
    QUERY
  end

  context 'Successful update' do
    subject { result }

    it 'returns the organization fields' do
      puts subject
      expect(subject['data']['saveAccount']).to include(
        'id' => user.slug,
        'displayName' => user_data['displayName'],
        'email' => user_data['email']
      )
    end
  end
end
