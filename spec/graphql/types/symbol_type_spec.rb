# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::SymbolType do
  let(:symbol) { create(:symbol) }
  let(:oms) { symbol.oms }

  let(:type) { OntohubBackendSchema.types['Symbol'] }
  let(:arguments) { {} }

  it_behaves_like 'having a GraphQL field with limit and skip', 'sentences' do
    let(:root) { symbol }
    let!(:available_items) do
      create_list(:sentence, 21, oms: oms).sort_by(&:loc_id)
    end

    before do
      available_items.each do |item|
        symbol.add_sentence(item)
      end
    end
  end

  it_behaves_like 'having a GraphQL field with limit and skip', 'signatures' do
    let(:root) { symbol }
    let!(:available_items) { create_list(:signature, 21).sort_by(&:id) }

    before do
      available_items.each do |item|
        item.add_symbol(symbol, false)
      end
    end
  end
end
