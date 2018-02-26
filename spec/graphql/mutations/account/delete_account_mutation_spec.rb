# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Account::DeleteAccountMutation do
  let!(:user) { create :user }
  let(:password) { user.password }

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
    mutation DeleteAccount($password: String!) {
      deleteAccount(password: $password)
    }
    QUERY
  end

  subject { result }

  context 'Correct password' do
    let(:variables) { {'password' => password} }

    it 'deletes the account' do
      subject
      expect(User.first(id: user.id)).to be(nil)
    end

    it 'enqueues a user indexing job' do
      subject
      expect(IndexingJob).to have_been_enqueued.with(
        'class' => 'User',
        'id' => user.id
      )
    end
  end

  shared_examples 'does not enque user indexing job' do
    it 'does not index' do
      expect(IndexingJob).not_to have_been_enqueued
    end
  end

  context 'Incorrect password' do
    let(:variables) { {'password' => "bad-#{password}"} }

    it 'does not delete the account' do
      subject
      expect(User.first(id: user.id)).to_not be(nil)
    end

    include_examples('does not enque user indexing job')
  end

  context 'Current user does not exist' do
    let(:variables) { {'password' => ''} }
    let(:context) { {current_user: nil} }

    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' => "You're not authorized to do this"))
    end

    it 'returns no data' do
      expect(subject['data']['deleteAccount']).to be(nil)
    end

    include_examples('does not enque user indexing job')
  end
end
