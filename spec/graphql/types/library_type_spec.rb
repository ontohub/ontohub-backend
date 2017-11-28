# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::LibraryType do
  let(:library) { create(:library) }

  let(:type) { OntohubBackendSchema.types['Library'] }
  let(:arguments) { {} }

  it_behaves_like 'having a GraphQL field with limit and skip', 'oms' do
    let(:root) { library }
    let!(:available_items) do
      create_list(:oms, 21, document: library).sort_by(&:loc_id)
    end
  end
end
