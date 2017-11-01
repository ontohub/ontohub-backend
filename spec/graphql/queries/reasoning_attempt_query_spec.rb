# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'reasoningAttempt query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: Int!) {
      reasoningAttempt(id: $id) {
        evaluationState
        generatedAxioms {
          id
        }
        id
        number
        reasonerConfiguration {
          id
        }
        reasonerOutput {
          reasoner {
            id
          }
          text
          reasoningAttempt {
            id
          }
        }
        reasoningStatus
        timeTaken
        usedReasoner {
          id
        }
        ... on ConsistencyCheckAttempt {
          oms {
            locId
          }
        }
        ... on ProofAttempt {
          conjecture {
            locId
          }
        }
      }
    }
    QUERY
  end

  let!(:consistency_check_attempt) do
    create(:consistency_check_attempt, time_taken: time_taken)
  end
  let!(:proof_attempt) { create(:proof_attempt, time_taken: time_taken) }
  let!(:generated_axioms) do
    create_list(:generated_axiom, 2, reasoning_attempt: reasoning_attempt)
  end
  let(:id) { reasoning_attempt.id }

  let(:variables_existent) { {'id' => id} }
  let(:variables_not_existent) { {'id' => 0} }

  let(:expectation_signed_in_existent) do
    match('data' => {'reasoningAttempt' => expected_reasoning_attempt})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'reasoningAttempt' => nil})
  end
  let(:expectation_not_signed_in_existent) do
    expectation_signed_in_existent
  end
  let(:expectation_not_signed_in_not_existent) do
    expectation_signed_in_not_existent
  end

  let(:expectation_base) do
    {
      'evaluationState' => reasoning_attempt.evaluation_state,
      'generatedAxioms' =>
        match_array(generated_axioms.map { |ga| {'id' => ga.id} }),
      'id' => reasoning_attempt.id,
      'number' => reasoning_attempt.number,
      'reasonerConfiguration' =>
        {'id' => reasoning_attempt.reasoner_configuration.id},
      'reasonerOutput' => expected_reasoner_output,
      'reasoningStatus' => reasoning_attempt.reasoning_status,
      'timeTaken' => expected_time_taken,
      'usedReasoner' => {'id' => reasoning_attempt.used_reasoner.to_param},
    }
  end

  shared_examples 'case reasonerOutput' do
    context 'with a reasonerOutput' do
      let!(:reasoner_output) do
        create(:reasoner_output, reasoning_attempt: reasoning_attempt)
      end
      let(:expected_reasoner_output) do
        {'reasoner' => {'id' => reasoner_output.reasoner.to_param},
         'text' => reasoner_output.text,
         'reasoningAttempt' => {'id' => reasoning_attempt.id}}
      end

      it_behaves_like 'a GraphQL query', 'reasoningAttempt'
    end

    context 'without a reasonerOutput' do
      let(:reasoner_output) { nil }
      let(:expected_reasoner_output) { nil }
    end
  end

  shared_examples 'case timeTaken' do
    context 'with timeTaken' do
      let(:time_taken) { rand(5) }
      let(:expected_time_taken) { time_taken }
      include_examples 'case reasonerOutput'
    end

    context 'without timeTaken' do
      let(:time_taken) { nil }
      let(:expected_time_taken) { nil }
      include_examples 'case reasonerOutput'
    end
  end

  context 'on ConsistencyCheckAttempt' do
    let(:reasoning_attempt) { consistency_check_attempt }
    let(:expected_reasoning_attempt) do
      oms = consistency_check_attempt.oms
      expectation_base.merge('oms' => {'locId' => oms.loc_id})
    end
    include_examples 'case timeTaken'
  end

  context 'on ProofAttempt' do
    let(:reasoning_attempt) { proof_attempt }
    let(:expected_reasoning_attempt) do
      conjecture = proof_attempt.conjecture
      expectation_base.merge('conjecture' => {'locId' => conjecture.loc_id})
    end
    include_examples 'case timeTaken'
  end
end
