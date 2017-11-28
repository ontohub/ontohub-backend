# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::SinePremiseSelectionType do
  let(:sine_premise_selection) { create(:sine_premise_selection) }

  let(:type) { OntohubBackendSchema.types['SinePremiseSelection'] }
  let(:arguments) { {} }

  it_behaves_like 'having a GraphQL field with limit and skip',
    'selectedPremises' do
    let(:root) { sine_premise_selection }
    let!(:available_items) do
      create_list(:sentence, 21).sort_by(&:loc_id)
    end

    before do
      available_items.each do |item|
        sine_premise_selection.add_selected_premise(item)
      end
    end
  end

  it_behaves_like 'having a GraphQL field with limit and skip',
    'sineSymbolCommonnesses' do
    let(:root) { sine_premise_selection }
    let!(:available_items) do
      create_list(:sine_symbol_commonness, 21,
                  sine_premise_selection: sine_premise_selection).sort_by(&:id)
    end
  end

  it_behaves_like 'having a GraphQL field with limit and skip',
    'sineSymbolPremiseTriggers' do
    let(:root) { sine_premise_selection }
    let!(:available_items) do
      create_list(:sine_symbol_premise_trigger, 21,
                  sine_premise_selection: sine_premise_selection).sort_by(&:id)
    end
  end
end
