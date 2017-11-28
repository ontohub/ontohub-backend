# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Language query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: ID!) {
      logic(id: $id) {
        id
        name
        language {
          id
        }
        logicMappings {
          id
        }
      }
    }
    QUERY
  end

  let!(:logic) { create(:logic) }

  let(:variables_existent) { {'id' => logic.to_param} }
  let(:variables_not_existent) { {'id' => "bad-#{logic.to_param}"} }

  let(:expectation_signed_in_existent) do
    match('data' => {'logic' => base_expectation})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'logic' => nil})
  end
  let(:expectation_not_signed_in_existent) do
    expectation_signed_in_existent
  end
  let(:expectation_not_signed_in_not_existent) do
    expectation_signed_in_not_existent
  end

  let(:base_expectation) do
    {
      'id' => logic.to_param,
      'name' => logic.name,
      'language' => include('id' => logic.language.to_param),
      'logicMappings' => expected_logic_mappings,
    }
  end
  let(:expected_logic_mappings) { [] }

  context 'with logicMappings' do
    let!(:logic_mapping) { create(:logic_mapping, source: logic) }
    let(:expected_logic_mappings) do
      include(include('id' => logic_mapping.to_param))
    end

    it_behaves_like 'a GraphQL query', 'logic'
  end

  context 'without associations' do
    it_behaves_like 'a GraphQL query', 'logic'
  end
end
