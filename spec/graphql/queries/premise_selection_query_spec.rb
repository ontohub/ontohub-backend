# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'premiseSelection query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: Int!) {
      premiseSelection(id: $id) {
        id
        reasonerConfiguration {
          id
        }
        selectedPremises {
          locId
        }
        ... on SinePremiseSelection {
          depthLimit
          premiseNumberLimit
          sineSymbolCommonnesses {
            commonness
            sinePremiseSelection {
              id
            }
            symbol {
              locId
            }
          }
          sineSymbolPremiseTriggers {
            minTolerance
            premise {
              locId
            }
            sinePremiseSelection {
              id
            }
            symbol {
              locId
            }
          }
          tolerance
        }
      }
    }
    QUERY
  end

  let(:current_user) { create(:user) }
  let(:reasoner_configuration) { create(:reasoner_configuration) }
  let(:oms) { create(:oms) }
  let(:selected_premises) { create_list(:axiom, 2, oms: oms).sort_by(&:loc_id) }
  let(:other_premises) { create_list(:axiom, 2, oms: oms) }
  before do
    proof_attempt =
      create(:proof_attempt, reasoner_configuration: reasoner_configuration)
    proof_attempt.repository.update(public_access: false,
                                    owner_id: current_user.id)
    selected_premises.each do |premise|
      premise_selection.add_selected_premise(premise)
    end
  end

  let(:variables_existent) { {'id' => premise_selection.id} }
  let(:variables_not_existent) { {'id' => 0} }

  let(:expectation_signed_in_existent) do
    match('data' => {'premiseSelection' => base_expectation})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'premiseSelection' => nil},
          'errors' => [include('message' => 'resource not found')])
  end
  let(:expectation_not_signed_in_existent) do
    expectation_signed_in_not_existent
  end
  let(:expectation_not_signed_in_not_existent) do
    expectation_signed_in_not_existent
  end

  let(:abstract_expectation) do
    {
      'id' => premise_selection.id,
      'reasonerConfiguration' =>
        {'id' => premise_selection.reasoner_configuration.id},
      'selectedPremises' => selected_premises.map { |p| {'locId' => p.loc_id} },
    }
  end

  context 'on a ManualPremiseSelection' do
    let(:premise_selection) do
      create(:manual_premise_selection,
             reasoner_configuration: reasoner_configuration)
    end
    let(:base_expectation) { abstract_expectation }
    it_behaves_like 'a GraphQL query', 'premiseSelection'
  end

  context 'on a SinePremiseSelection' do
    let(:premise_selection) do
      create(:sine_premise_selection,
             reasoner_configuration: reasoner_configuration)
    end
    let!(:sine_symbol_commonnesses) do
      create_list(:sine_symbol_commonness, 2,
                  sine_premise_selection: premise_selection).sort_by(&:id)
    end

    let!(:sine_symbol_premise_triggers) do
      create_list(:sine_symbol_premise_trigger, 2,
                  sine_premise_selection: premise_selection).sort_by(&:id)
    end

    let(:base_expectation) do
      expected_commonnesses = sine_symbol_commonnesses.map do |ssc|
        {
          'commonness' => ssc.commonness,
          'sinePremiseSelection' => {'id' => premise_selection.id},
          'symbol' => {'locId' => ssc.symbol.loc_id},
        }
      end
      expected_triggers = sine_symbol_premise_triggers.map do |sspt|
        {
          'minTolerance' => sspt.min_tolerance,
          'premise' => {'locId' => sspt.premise.loc_id},
          'sinePremiseSelection' => {'id' => premise_selection.id},
          'symbol' => {'locId' => sspt.symbol.loc_id},
        }
      end
      abstract_expectation.merge(
        'depthLimit' => premise_selection.depth_limit,
        'premiseNumberLimit' => premise_selection.premise_number_limit,
        'sineSymbolCommonnesses' => expected_commonnesses,
        'sineSymbolPremiseTriggers' => expected_triggers,
        'tolerance' => premise_selection.tolerance
      )
    end
    it_behaves_like 'a GraphQL query', 'premiseSelection'
  end
end
