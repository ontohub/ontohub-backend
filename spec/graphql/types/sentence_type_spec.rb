# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::SentenceType do
  let(:sentence) { create(:sentence) }
  let(:oms) { sentence.oms }

  let(:type) { OntohubBackendSchema.types['Sentence'] }
  let(:arguments) { {} }

  it_behaves_like 'having a GraphQL field with limit and skip', 'symbols' do
    let(:root) { sentence }
    let!(:available_items) do
      create_list(:symbol, 21, oms: oms).sort_by(&:loc_id)
    end

    before do
      available_items.each do |item|
        sentence.add_symbol(item)
      end
    end
  end
end
