# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::SignatureType do
  let(:signature) { create(:signature) }
  let(:oms) { create(:oms, signature: signature) }

  let(:type) { OntohubBackendSchema.types['Signature'] }
  let(:arguments) { {} }

  context 'signatureMorphisms field' do
    it_behaves_like 'having a GraphQL field with origin and limit and skip',
      'signatureMorphisms' do
      let(:root) { signature }
      let(:links_source) do
        create_list(:signature_morphism, 21, source: signature).sort_by(&:id)
      end
      let(:links_target) do
        create_list(:signature_morphism, 21, target: signature).sort_by(&:id)
      end
      let!(:links_all) do
        (links_source + links_target).sort_by(&:id)
      end
    end
  end

  context 'symbols field' do
    let(:root) { signature }
    let!(:imported_symbols) do
      create_list(:symbol, 21, oms: oms).sort_by(&:loc_id)
    end
    let!(:non_imported_symbols) do
      create_list(:symbol, 21, oms: oms).sort_by(&:loc_id)
    end

    before do
      imported_symbols.each do |symbol|
        signature.add_symbol(symbol, true)
      end
      non_imported_symbols.each do |symbol|
        signature.add_symbol(symbol, false)
      end
    end

    context 'with argument origin: either' do
      let(:arguments) { {'origin' => 'either'} }

      it_behaves_like 'having a GraphQL field with limit and skip',
        'symbols' do
        let!(:available_items) do
          (imported_symbols + non_imported_symbols).sort_by(&:loc_id)
        end
      end
    end

    context 'with argument origin: imported' do
      let(:arguments) { {'origin' => 'imported'} }

      it_behaves_like 'having a GraphQL field with limit and skip',
        'symbols' do
        let!(:available_items) { imported_symbols }
      end
    end

    context 'with argument origin: non_imported' do
      let(:arguments) { {'origin' => 'non_imported'} }

      it_behaves_like 'having a GraphQL field with limit and skip',
        'symbols' do
        let!(:available_items) { non_imported_symbols }
      end
    end
  end
end
