# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'OrganizationalUnit query' do
  let!(:user) { create :user }
  let!(:organization) { create :organization }

  before do
    organization.add_member(user)
  end

  let(:context) { {} }
  let(:variables) { {'id' => subject.slug} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    query OrganizationalUnit($id: ID!) {
      organizationalUnit(id: $id) {
        id
        displayName
        ... on User {
          email
          emailHash
          publicKeys {
            key
            name
          }
          organizations {
            id
          }
        }
        ... on Organization {
          description
          members {
            id
          }
        }
      }
    }
    QUERY
  end

  context 'User' do
    subject { user }

    context 'authorized to see private data' do
      let(:context) { {current_user: subject} }

      it 'returns the user fields' do
        user = result['data']['organizationalUnit']
        expect(user).to include(
          'id' => subject.slug,
          'displayName' => subject.display_name,
          'email' => subject.email,
          'emailHash' => subject.email_hash,
          'publicKeys' => subject.public_keys,
          'organizations' => [{'id' => organization.slug}]
        )
      end
    end

    context 'unauthorized to see private data' do
      it 'returns the user fields' do
        user = result['data']['organizationalUnit']
        expect(user).to include(
          'id' => subject.slug,
          'displayName' => subject.display_name,
          'email' => nil,
          'emailHash' => subject.email_hash,
          'publicKeys' => nil,
          'organizations' => [{'id' => organization.slug}]
        )
      end
    end
  end

  context 'Organization' do
    subject { organization }

    it 'returns the organization fields' do
      organization = result['data']['organizationalUnit']
      expect(organization).to include(
        'id' => subject.slug,
        'displayName' => subject.display_name,
        'description' => subject.description,
        'members' => [{'id' => user.slug}]
      )
    end
  end
end
