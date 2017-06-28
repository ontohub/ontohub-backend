# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'createOrganization mutation' do
  let!(:current_user) { create :user }
  let(:organization_data) do
    {
      'id' => 'foobar',
      'displayName' => 'Foobar',
      'description' => 'This is the foobar',
    }
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
        members {
          id
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
        'members' => [{'id' => current_user.slug}]
      )
    end
  end

  context 'Name is not available' do
    before do
      create :organization, name: organization_data['id']
    end

    it 'returns an error' do
      expect(subject['data']['createOrganization']).to be(nil)
      expect(subject['errors']).
        to include(include('message' => 'name is already taken'))
    end
  end
end