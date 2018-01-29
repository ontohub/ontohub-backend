# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Language query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: ID!) {
      language(id: $id) {
        id
        name
        description
        definedBy
        standardizationStatus
        languageMappings {
          id
        }
        logics {
          id
        }
      }
    }
    QUERY
  end

  let!(:language) { create(:language) }

  let(:variables_existent) { {'id' => language.to_param} }
  let(:variables_not_existent) { {'id' => "bad-#{language.to_param}"} }

  let(:expectation_signed_in_existent) do
    match('data' => {'language' => base_expectation})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'language' => nil})
  end
  let(:expectation_not_signed_in_existent) do
    expectation_signed_in_existent
  end
  let(:expectation_not_signed_in_not_existent) do
    expectation_signed_in_not_existent
  end

  let(:base_expectation) do
    {
      'id' => language.to_param,
      'name' => language.name,
      'description' => language.description,
      'definedBy' => language.defined_by,
      'standardizationStatus' => language.standardization_status,
      'languageMappings' => expected_language_mappings,
      'logics' => expected_logics,
    }
  end
  let(:expected_language_mappings) { [] }
  let(:expected_logics) { [] }

  context 'with languageMappings' do
    let!(:language_mapping) { create(:language_mapping, source: language) }
    let(:expected_language_mappings) do
      include(include('id' => language_mapping.pk))
    end

    it_behaves_like 'a GraphQL query', 'language'
  end

  context 'with logics' do
    let!(:logic) { create(:logic, language: language) }
    let(:expected_logics) { include(include('id' => logic.to_param)) }

    it_behaves_like 'a GraphQL query', 'language'
  end

  context 'without associations' do
    it_behaves_like 'a GraphQL query', 'language'
  end
end
