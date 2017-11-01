# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'reasoner_configuration query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: Int!) {
      reasonerConfiguration(id: $id) {
        id
        configuredReasoner {
          id
        }
        premiseSelections {
          id
        }
        reasoningAttempts {
          id
        }
      }
    }
    QUERY
  end

  let!(:reasoner_configuration) do
    create(:reasoner_configuration, configured_reasoner: reasoner)
  end
  let!(:premise_selections) do
    create_list(:premise_selection, 2,
                reasoner_configuration: reasoner_configuration)
  end
  let!(:reasoning_attempts) do
    create_list(:proof_attempt, 2,
                reasoner_configuration: reasoner_configuration)
  end

  let(:variables_existent) { {'id' => reasoner_configuration.id} }
  let(:variables_not_existent) { {'id' => 0} }

  let(:expectation_signed_in_existent) do
    match('data' => {'reasonerConfiguration' => base_expectation})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'reasonerConfiguration' => nil})
  end
  let(:expectation_not_signed_in_existent) do
    expectation_signed_in_existent
  end
  let(:expectation_not_signed_in_not_existent) do
    expectation_signed_in_not_existent
  end

  let(:base_expectation) do
    {
      'id' => reasoner_configuration.id,
      'configuredReasoner' => expected_reasoner,
      'premiseSelections' => premise_selections.map { |p| {'id' => p.id} },
      'reasoningAttempts' => reasoning_attempts.map { |a| {'id' => a.id} },
    }
  end

  context 'with configured reasoner' do
    let(:reasoner) { create(:reasoner) }
    let(:expected_reasoner) { {'id' => reasoner.to_param} }

    it_behaves_like 'a GraphQL query', 'reasonerConfiguration'
  end

  context 'without configured reasoner' do
    let(:reasoner) { nil }
    let(:expected_reasoner) { nil }

    it_behaves_like 'a GraphQL query', 'reasonerConfiguration'
  end
end
