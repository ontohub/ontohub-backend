# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'reasoner query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: ID!) {
      reasoner(id: $id) {
        id
        displayName
      }
    }
    QUERY
  end

  let!(:reasoner) { create(:reasoner) }

  let(:variables_existent) { {'id' => reasoner.to_param} }
  let(:variables_not_existent) { {'id' => "bad-#{reasoner.to_param}"} }

  let(:expectation_signed_in_existent) do
    match('data' => {'reasoner' => base_expectation})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'reasoner' => nil})
  end
  let(:expectation_not_signed_in_existent) do
    expectation_signed_in_existent
  end
  let(:expectation_not_signed_in_not_existent) do
    expectation_signed_in_not_existent
  end

  let(:base_expectation) do
    {
      'id' => reasoner.to_param,
      'displayName' => reasoner.display_name,
    }
  end

  it_behaves_like 'a GraphQL query', 'reasoner'
end
