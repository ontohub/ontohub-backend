# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::PremiseSelectionType do
  let(:premise_selection) { create(:premise_selection) }

  let(:type) { OntohubBackendSchema.types['PremiseSelection'] }
  let(:arguments) { {} }

  it_behaves_like 'having a GraphQL field with limit and skip',
    'selectedPremises' do
    let(:root) { premise_selection }
    let!(:available_items) do
      create_list(:sentence, 21).sort_by(&:loc_id)
    end

    before do
      available_items.each do |item|
        premise_selection.add_selected_premise(item)
      end
    end
  end
end
