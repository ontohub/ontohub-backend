# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LogicMapping query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: ID!) {
      logicMapping(id: $id) {
        id
        source {
          id
        }
        target {
          id
        }
        languageMapping {
          id
        }
      }
    }
    QUERY
  end

  let!(:logic_mapping) { create(:logic_mapping) }

  it_behaves_like 'a GraphQL query', 'logicMapping' do
    let(:variables_existent) { {'id' => logic_mapping.to_param} }
    let(:variables_not_existent) { {'id' => 0} }
    let(:expectation_signed_in_existent) do
      match('data' => {'logicMapping' => include(
        'id' => logic_mapping.to_param,
        'source' => include('id' => logic_mapping.source.to_param),
        'target' => include('id' => logic_mapping.target.to_param),
        'languageMapping' =>
          include('id' => logic_mapping.language_mapping.to_param)
      )})
    end
    let(:expectation_signed_in_not_existent) do
      match('data' => {'logicMapping' => nil})
    end
    let(:expectation_not_signed_in_existent) do
      expectation_signed_in_existent
    end
    let(:expectation_not_signed_in_not_existent) do
      expectation_signed_in_not_existent
    end
  end
end
