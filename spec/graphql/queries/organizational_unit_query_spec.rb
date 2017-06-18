# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OntohubBackendSchema do
  let!(:user) { create :user }
  let!(:organization) { create :organization }

  before do
    organization.add_member(user)
  end

  let(:context) { {} }
  let(:variables) { {"id" => subject.slug} }

  let(:result) do
    res = OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
    puts res if res['errors']
    res
  end

  describe 'OrganizationalUnit query' do
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

    describe 'User' do
      subject { user }

      it 'returns the user fields' do
        user = result['data']['organizationalUnit']
        expect(user).to include(
          'id' => subject.slug,
          'displayName' => subject.display_name,
          'email' => subject.email,
          'emailHash' => Digest::MD5.hexdigest(subject.email),
          'organizations' => [
            {'id' => organization.slug}
          ]
        )
      end
    end

    describe 'Organization' do
      subject { organization }

      it 'returns the organization fields' do
        organization = result['data']['organizationalUnit']
        expect(organization).to include(
          'id' => subject.slug,
          'displayName' => subject.display_name,
          'description' => subject.description,
          'members' => [
            {'id' => user.slug}
          ]
        )
      end
    end
  end
end
