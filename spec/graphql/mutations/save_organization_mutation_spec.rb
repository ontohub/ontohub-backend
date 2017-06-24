# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'saveOrganization mutation' do
  let!(:organization) { create :organization }
  let(:organization_data) do
    {
      'displayName' => 'Foobar',
      'description' => 'This is the foobar'
    }
  end

  let(:context) { {} }
  let(:variables) { {'id' => organization.slug, 'data' => organization_data} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation SaveOrganization($id: ID!, $data: OrganizationChangeset!) {
      saveOrganization(id: $id, data: $data) {
        id
        displayName
        description
      }
    }
    QUERY
  end

  context 'Successful update' do
    subject { result }

    it 'returns the organization fields' do
      expect(subject['data']['saveOrganization']).to include(
        'id' => organization.slug,
        'description' => organization_data['description'],
        'displayName' => organization_data['displayName']
      )
    end
  end
end
