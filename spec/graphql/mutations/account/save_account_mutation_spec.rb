# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'saveAccount mutation' do
  let!(:user) { create :user }
  let(:password) { user.password }
  let(:new_password) { "changed-#{password}" }
  let(:user_data) do
    user = build :user
    user.values.slice(:display_name, :email, :password).
      transform_keys { |k| k.to_s.camelize(:lower) }.
      merge('password' => new_password)
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

  subject { result }

  context 'Correct password' do
    let(:variables) { {'data' => user_data, 'password' => password} }

    it 'returns the new account fields' do
      expect(subject['data']['saveAccount']).to include(
        'id' => user.slug,
        'displayName' => user_data['displayName'],
        'email' => user.email,
        'unconfirmedEmail' => user_data['email']
      )
    end

    it "changed the user's password" do
      subject
      expect(user.valid_password?(new_password)).to be_truthy
    end
  end

  context 'Incorrect password' do
    let(:variables) { {'data' => user_data, 'password' => "bad-#{password}"} }

    it 'returns the old account fields' do
      expect(subject['data']['saveAccount']).to include(
        'id' => user.slug,
        'displayName' => user.display_name,
        'email' => user.email
      )
    end
  end

  context 'User is not signed in' do
    let(:variables) { {'data' => user_data, 'password' => ''} }
    let(:context) { {current_user: nil} }

    it 'returns an error' do
      expect(subject['data']['saveAccount']).to be_nil
      expect(subject['errors']).
        to include(include('message' => "You're not authorized to do this"))
    end
  end
end
