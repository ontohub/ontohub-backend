# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Organization::CreateOrganizationMutation do
  let!(:current_user) { create :user }
  let(:organization_data) do
    org = build :organization
    org.send(:set_slug)
    org.values.slice(:slug, :display_name, :description).
      transform_keys { |k| k == :slug ? 'id' : k.to_s.camelize(:lower) }
  end

  let(:context) { {current_user: current_user} }
  let(:variables) { {'data' => organization_data} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation CreateOrganization($data: NewOrganization!) {
      createOrganization(data: $data) {
        id
        displayName
        description
        memberships {
          member {
            id
          }
          organization {
            id
          }
          role
        }
      }
    }
    QUERY
  end

  subject { result }

  context 'Successful creation' do
    it 'returns the organization fields' do
      expect(subject['data']['createOrganization']).to include(
        'id' => organization_data['id'],
        'description' => organization_data['description'],
        'displayName' => organization_data['displayName'],
        'memberships' => [
          {'member' => {'id' => current_user.slug},
           'organization' => {'id' => organization_data['id']},
           'role' => 'read'},
        ]
      )
    end
  end

  context 'Name is not available' do
    before do
      create :organization, name: organization_data['id']
    end

    it 'returns no data' do
      expect(subject['data']['createOrganization']).to be(nil)
    end

    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' => 'name is already taken'))
    end
  end

  context 'Not signed in' do
    let(:context) { {} }

    it 'returns no data' do
      expect(subject['data']['createOrganization']).to be(nil)
    end

    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' => "You're not authorized to do this"))
    end
  end
end
