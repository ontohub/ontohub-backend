# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'signatureMorphism query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: Int!) {
      signatureMorphism(id: $id) {
        asJson
        id
        logicMapping {
          id
        }
        mappings {
          locId
        }
        source {
          id
        }
        target {
          id
        }
        symbolMappings {
          source {
            locId
          }
          target {
            locId
          }
        }
      }
    }
    QUERY
  end

  let(:current_user) { create(:user) }
  let!(:signature_morphism) { create(:signature_morphism) }
  let!(:repository) do
    create(:oms, signature: signature_morphism.source).repository
  end
  let!(:mappings) do
    create_list(:mapping, 2, signature_morphism: signature_morphism)
  end
  let!(:symbol_mappings) do
    create_list(:symbol_mapping, 2, signature_morphism: signature_morphism)
  end
  before do
    signature_morphism.repositories.each do |repository|
      repository.update(public_access: false, owner_id: current_user.id)
    end
  end

  it_behaves_like 'a GraphQL query', 'signatureMorphism' do
    let(:variables_existent) { {'id' => signature_morphism.id} }
    let(:variables_not_existent) { {'id' => 0} }
    let(:expectation_signed_in_existent) do
      signature_morphism_data = {
        'asJson' => be_present,
        'id' => signature_morphism.id,
        'source' => {'id' => signature_morphism.source.id},
        'target' => {'id' => signature_morphism.target.id},
        'logicMapping' => {'id' => signature_morphism.logic_mapping.to_param},
        'mappings' => match_array(mappings.map { |m| {'locId' => m.loc_id} }),
        'symbolMappings' => match_array(symbol_mappings.map do |symbol_mapping|
          {'source' => {'locId' => symbol_mapping.source.loc_id},
           'target' => {'locId' => symbol_mapping.target.loc_id}}
        end),
      }
      match('data' => {'signatureMorphism' => signature_morphism_data})
    end
    let(:expectation_signed_in_not_existent) do
      match('data' => {'signatureMorphism' => nil},
            'errors' => [include('message' => 'resource not found')])
    end
    let(:expectation_not_signed_in_existent) do
      expectation_signed_in_not_existent
    end
    let(:expectation_not_signed_in_not_existent) do
      expectation_signed_in_not_existent
    end
  end
end
