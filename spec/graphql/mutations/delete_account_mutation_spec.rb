# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'deleteAccount mutation' do
  let!(:user) { create :user, password: 'changemenow' }

  let(:context) { {} }

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

  context 'Correct password' do
    let(:variables) { {'password' => 'changemenow'} }
    subject { result }

    it 'deletes the account' do
      expect(User.find(id: user.id)).to be(nil)
    end
  end

  context 'Incorrect password' do
    let(:variables) { {'password' => 'changemeow'} }
    subject { result }

    it 'does not delete the account' do
      expect(User.find(id: user.id)).to_not be(nil)
    end
  end
end
