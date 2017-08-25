# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'removePublicKey mutation' do
  let!(:user) { create :user }
  let(:key) { Base64.strict_encode64('some-rsa-key') }
  let(:key_name) { 'stub@localhost' }
  let!(:existing_key) { create :public_key, user: user, name: key_name }

  let(:context) { {current_user: current_user} }
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
    mutation RemovePublicKey($name: String!) {
      removePublicKey(name: $name)
    }
    QUERY
  end

  subject { result }

  context 'User is signed in' do
    let(:current_user) { user }
    before { subject }

    context 'valid key name' do
      let(:variables) { {'name' => key_name} }

      it 'deletes the key' do
        expect(PublicKey.count(user: user, name: key_name)).to eq(0)
      end

      it 'returns true' do
        expect(subject['data']['removePublicKey']).to be_truthy
      end
    end

    context 'invalid key name' do
      let(:variables) { {'name' => "invalid-#{key_name}"} }
      it 'returns an error' do
        expect(subject['errors']).
          to include(include('message' => 'Public key not found'))
      end
    end
  end

  context 'User is not signed in' do
    let(:current_user) { nil }

    it 'returns an error' do
      # TODO: Needs authorization
    end
  end
end
