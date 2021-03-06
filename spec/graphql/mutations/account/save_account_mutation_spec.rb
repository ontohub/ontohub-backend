# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Account::SaveAccountMutation do
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

    it 'enqueues a user indexing job' do
      subject
      expect(IndexingJob).to have_been_enqueued.with(
        'class' => 'User',
        'id' => User.
          first(slug: result['data']['saveAccount']['id']).id
      )
    end
  end

  shared_examples 'does not enque user indexing job' do
    it 'does not index' do
      expect(IndexingJob).not_to have_been_enqueued
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

    include_examples('does not enque user indexing job')
  end

  context 'User is not signed in' do
    let(:variables) { {'data' => user_data, 'password' => ''} }
    let(:context) { {current_user: nil} }

    it 'returns no data' do
      expect(subject['data']['saveAccount']).to be(nil)
    end

    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' => "You're not authorized to do this"))
    end

    include_examples('does not enque user indexing job')
  end
end
