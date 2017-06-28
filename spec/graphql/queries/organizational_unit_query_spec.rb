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

    it 'returns the user fields' do
      user = result['data']['organizationalUnit']
      expect(user).to include(
        'id' => subject.slug,
        'displayName' => subject.display_name,
        'email' => subject.email,
        'emailHash' => subject.email_hash,
        'organizations' => [{'id' => organization.slug}]
      )
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
