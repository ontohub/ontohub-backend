# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'saveOrganization mutation' do
  let!(:organization) { create :organization }
  let(:organization_data) do
    org = build :organization
    org.values.slice(:display_name, :description).
      transform_keys { |k| k.to_s.camelize(:lower) }
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

  subject { result }

  context 'Successful update' do
    it 'returns the organization fields' do
      expect(subject['data']['saveOrganization']).to include(
        'id' => organization.slug,
        'description' => organization_data['description'],
        'displayName' => organization_data['displayName']
      )
    end
  end

  context 'Organization does not exist' do
    let(:variables) do
      {'id' => "bad-#{organization.slug}",
       'data' => organization_data}
    end

    it 'returns an error' do
      expect(subject['data']['saveOrganization']).to be_nil
      expect(subject['errors']).
        to include(include('message' => 'resource not found'))
    end
  end
end
