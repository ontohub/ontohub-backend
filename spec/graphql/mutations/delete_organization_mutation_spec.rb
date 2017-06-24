# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'deleteOrganization mutation' do
  let!(:organization) { create :organization }

  let(:context) { {} }
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

  context 'Successful delete' do
    subject { result }

    it 'returns true' do
      expect(subject['data']['deleteOrganization']).to be(true)
    end
  end
end
