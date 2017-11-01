# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'generatedAxiom query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: Int!) {
      generatedAxiom(id: $id) {
        id
        reasoningAttempt {
          id
        }
        text
      }
    }
    QUERY
  end

  let!(:generated_axiom) { create(:generated_axiom) }

  let(:variables_existent) { {'id' => generated_axiom.id} }
  let(:variables_not_existent) { {'id' => 0} }

  let(:expectation_signed_in_existent) do
    match('data' => {'generatedAxiom' => base_expectation})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'generatedAxiom' => nil})
  end
  let(:expectation_not_signed_in_existent) do
    expectation_signed_in_existent
  end
  let(:expectation_not_signed_in_not_existent) do
    expectation_signed_in_not_existent
  end

  let(:base_expectation) do
    {
      'id' => generated_axiom.id,
      'reasoningAttempt' => {'id' => generated_axiom.reasoning_attempt.id},
      'text' => generated_axiom.text,
    }
  end

  it_behaves_like 'a GraphQL query', 'generatedAxiom'
end
