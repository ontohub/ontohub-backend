# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/commit/sentence query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $commitRevision: ID!, $locId: ID!) {
      repository(id: $repositoryId) {
        commit(revision: $commitRevision) {
          sentence(locId: $locId) {
            fileRange {
              path
              startLine
              startColumn
              endLine
              endColumn
            }
            fileVersion {
              path
            }
            locId
            name
            oms {
              locId
            }
            symbols {
              locId
            }
            text
            ... on OpenConjecture {
              action {
                evaluationState
                message
              }
              proofStatus
              proofAttempts {
                id
              }
            }
            ... on CounterTheorem {
              action {
                evaluationState
                message
              }
              proofStatus
              proofAttempts {
                id
              }
            }
            ... on Theorem {
              action {
                evaluationState
                message
              }
              proofStatus
              proofAttempts {
                id
              }
            }
          }
        }
      }
    }
    QUERY
  end

  let(:repository) do
    create(:repository_compound, :not_empty,
           public_access: false,
           owner: current_user)
  end
  let(:git) { repository.git }
  let(:commit) { git.commit(git.default_branch) }
  let(:file_version) do
    create(:file_version, repository: repository, commit_sha: commit.id)
  end
  let(:document) { create(:library, file_version: file_version) }
  let(:oms) { create(:oms, document: document) }
  let!(:axiom) { create(:axiom, oms: oms, file_range: file_range) }
  let!(:open_conjecture) do
    create(:open_conjecture, oms: oms, file_range: file_range)
  end
  let!(:counter_theorem) do
    create(:counter_theorem, oms: oms, file_range: file_range)
  end
  let!(:theorem) { create(:theorem, oms: oms, file_range: file_range) }
  let!(:proof_attempts) do
    create_list(:proof_attempt, 2, conjecture: conjecture).sort_by(&:id)
  end
  let(:symbols) { create_list(:symbol, 2, oms: oms) }
  before do
    symbols.each { |s| sentence.add_symbol(s) }
  end

  let(:current_user) { create(:user) }
  let(:variables_base) do
    {'repositoryId' => repository.to_param,
     'commitRevision' => commit.id}
  end

  let(:variables_existent) do
    variables_base.merge('locId' => sentence.loc_id)
  end
  let(:variables_not_existent) do
    variables_base.merge('locId' => "bad-#{sentence.loc_id}")
  end

  let(:expectation_signed_in_existent) do
    match('data' => {'repository' => {'commit' => {'sentence' =>
                                                     sentence_data}}})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'repository' => {'commit' => {'sentence' => nil}}})
  end
  let(:expectation_not_signed_in_existent) do
    match('data' => {'repository' => nil})
  end

  let(:expectation_not_signed_in_not_existent) do
    expectation_not_signed_in_existent
  end

  let(:axiom_data) do
    {
      'fileRange' => expected_file_range,
      'fileVersion' => {'path' => file_version.path},
      'locId' => sentence.loc_id,
      'name' => sentence.name,
      'oms' => {'locId' => oms.loc_id},
      'symbols' => match_array(symbols.map { |s| {'locId' => s.loc_id} }),
      'text' => sentence.text,
    }
  end

  let(:conjecture_data) do
    axiom_data.merge(
      'action' => {
        'evaluationState' => conjecture.action.evaluation_state,
        'message' => conjecture.action.message,
      },
      'proofStatus' => conjecture.proof_status,
      'proofAttempts' => proof_attempts.map { |pa| {'id' => pa.id} }
    )
  end

  shared_examples 'query behavior' do
    context 'with fileRange' do
      let(:file_range) { create(:file_range) }
      let(:expected_file_range) do
        {
          'path' => file_range.path,
          'startLine' => file_range.start_line,
          'startColumn' => file_range.start_column,
          'endLine' => file_range.end_line,
          'endColumn' => file_range.end_column,
        }
      end

      it_behaves_like 'a GraphQL query', %w(repository commit sentence)
    end

    context 'without fileRange' do
      let(:file_range) { nil }
      let(:expected_file_range) { nil }
      it_behaves_like 'a GraphQL query', %w(repository commit sentence)
    end
  end

  context 'on Axiom' do
    let(:conjecture) { theorem } # not relevant in this context
    let(:sentence) { axiom }
    let(:sentence_data) { axiom_data }
    include_examples 'query behavior'
  end

  context 'on OpenConjecture' do
    let(:conjecture) { sentence }
    let(:sentence) { open_conjecture }
    let(:sentence_data) { conjecture_data }
    include_examples 'query behavior'
  end

  context 'on CounterTheorem' do
    let(:conjecture) { sentence }
    let(:sentence) { counter_theorem }
    let(:sentence_data) { conjecture_data }
    include_examples 'query behavior'
  end

  context 'on Theorem' do
    let(:conjecture) { sentence }
    let(:sentence) { theorem }
    let(:sentence_data) { conjecture_data }
    include_examples 'query behavior'
  end
end
