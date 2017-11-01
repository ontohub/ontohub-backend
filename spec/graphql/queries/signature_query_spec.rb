# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'signature query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: Int!) {
      signature(id: $id) {
        id
        asJson
        symbols {
          locId
        }
        importedSymbols: symbols(origin: imported) {
          locId
        }
        nonImportedSymbols: symbols(origin: non_imported) {
          locId
        }
        oms {
          locId
        }
        signatureMorphisms {
          id
        }
        signatureMorphismsBySource: signatureMorphisms(origin: source) {
          id
        }
        signatureMorphismsByTarget: signatureMorphisms(origin: target) {
          id
        }
      }
    }
    QUERY
  end

  let!(:signature) { create(:signature) }
  let!(:oms) { create_list(:oms, 2, signature: signature) }
  let!(:imported_symbols) { create_list(:symbol, 2).sort_by(&:loc_id) }
  let!(:non_imported_symbols) { create_list(:symbol, 2).sort_by(&:loc_id) }
  let(:symbols) { (imported_symbols + non_imported_symbols).sort_by(&:loc_id) }
  before do
    imported_symbols.each { |s| signature.add_symbol(s, true) }
    non_imported_symbols.each { |s| signature.add_symbol(s, false) }
  end
  let!(:signature_morphisms_source) do
    create_list(:signature_morphism, 2, source: signature).sort_by(&:id)
  end
  let!(:signature_morphisms_target) do
    create_list(:signature_morphism, 2, target: signature).sort_by(&:id)
  end
  let(:signature_morphisms) do
    (signature_morphisms_source + signature_morphisms_target).sort_by(&:id)
  end

  let(:variables_existent) { {'id' => signature.id} }
  let(:variables_not_existent) { {'id' => 0} }

  let(:expectation_signed_in_existent) do
    match('data' => {'signature' => base_expectation})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'signature' => nil})
  end
  let(:expectation_not_signed_in_existent) do
    expectation_signed_in_existent
  end
  let(:expectation_not_signed_in_not_existent) do
    expectation_signed_in_not_existent
  end

  let(:base_expectation) do
    {
      'id' => signature.id,
      'asJson' => be_present,
      'symbols' => symbols.map { |s| {'locId' => s.loc_id} },
      'importedSymbols' => imported_symbols.map { |s| {'locId' => s.loc_id} },
      'nonImportedSymbols' =>
        non_imported_symbols.map { |s| {'locId' => s.loc_id} },
      'oms' => oms.map { |o| {'locId' => o.loc_id} },
      'signatureMorphisms' => signature_morphisms.map { |m| {'id' => m.id} },
      'signatureMorphismsBySource' =>
        signature_morphisms_source.map { |m| {'id' => m.id} },
      'signatureMorphismsByTarget' =>
        signature_morphisms_target.map { |m| {'id' => m.id} },
    }
  end

  it_behaves_like 'a GraphQL query', 'signature'
end
