# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'reasoningAttempt query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: Int!) {
      reasoningAttempt(id: $id) {
        action {
          evaluationState
          message
        }
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
        timeTaken
        usedReasoner {
          id
        }
        ... on ConsistencyCheckAttempt {
          consistencyStatus
          oms {
            locId
          }
        }
        ... on ProofAttempt {
          proofStatus
          conjecture {
            locId
          }
          usedSentences {
            locId
          }
        }
      }
    }
    QUERY
  end

  let(:current_user) { create(:user) }
  let!(:consistency_check_attempt) do
    create(:consistency_check_attempt, time_taken: time_taken)
  end
  let!(:proof_attempt) { create(:proof_attempt, time_taken: time_taken) }
  let!(:used_sentences) { create_list(:sentence, 2) }
  before do
    used_sentences.each do |used_sentence|
      proof_attempt.add_used_sentence(used_sentence)
    end
  end
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
    match('data' => {'reasoningAttempt' => nil},
          'errors' => [include('message' => 'resource not found')])
  end
  let(:expectation_not_signed_in_existent) do
    expectation_signed_in_not_existent
  end
  let(:expectation_not_signed_in_not_existent) do
    expectation_signed_in_not_existent
  end

  let(:expectation_base) do
    {
      'action' => {
        'evaluationState' => reasoning_attempt.action.evaluation_state,
        'message' => reasoning_attempt.action.message,
      },
      'generatedAxioms' =>
        match_array(generated_axioms.map { |ga| {'id' => ga.id} }),
      'id' => reasoning_attempt.id,
      'number' => reasoning_attempt.number,
      'reasonerConfiguration' =>
        {'id' => reasoning_attempt.reasoner_configuration.id},
      'reasonerOutput' => expected_reasoner_output,
      reasoning_status_key => reasoning_status,
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
    let(:reasoning_status_key) { 'consistencyStatus' }
    let(:reasoning_status) { consistency_check_attempt.consistency_status }
    let(:expected_reasoning_attempt) do
      oms = consistency_check_attempt.oms
      expectation_base.merge('oms' => {'locId' => oms.loc_id})
    end
    before do
      reasoning_attempt.repository.update(public_access: false,
                                          owner_id: current_user.id)
    end
    include_examples 'case timeTaken'
  end

  context 'on ProofAttempt' do
    let(:reasoning_attempt) { proof_attempt }
    let(:reasoning_status_key) { 'proofStatus' }
    let(:reasoning_status) { proof_attempt.proof_status }
    let(:expected_reasoning_attempt) do
      conjecture = proof_attempt.conjecture
      expectation_base.merge('conjecture' => {'locId' => conjecture.loc_id},
                             'usedSentences' => used_sentences.map do |sentence|
                                                  {'locId' => sentence.loc_id}
                                                end)
    end
    before do
      reasoning_attempt.repository.update(public_access: false,
                                          owner_id: current_user.id)
    end
    include_examples 'case timeTaken'
  end
end
