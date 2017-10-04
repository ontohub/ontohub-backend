# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Organization::DeleteOrganizationMutation do
  let!(:organization) { create :organization }

  let(:membership) do
    create :organization_membership, organization_id: organization.id,
                                     role: :admin
  end
  let(:admin) { membership.member }
  let(:context) { {current_user: admin} }
  let(:variables) { {'id' => organization.slug} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation DeleteOrganization($id: ID!) {
      deleteOrganization(id: $id)
    }
    QUERY
  end

  subject { result }

  context 'Successful delete' do
    it 'returns true' do
      expect(subject['data']['deleteOrganization']).to be(true)
    end
  end

  context 'Organization does not exist' do
    let(:variables) { {'id' => organization.slug + 'foo'} }

    it 'returns an error' do
      expect(subject['data']['deleteOrganization']).to be_nil
      expect(subject['errors']).
        to include(include('message' => 'resource not found'))
    end
  end

  context 'Not signed in' do
    let(:context) { {} }

    it 'returns no data' do
      expect(subject['data']['deleteOrganization']).to be(nil)
    end

    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' => "You're not authorized to do this"))
    end
  end
end
