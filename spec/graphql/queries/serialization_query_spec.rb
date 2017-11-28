# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Serialization query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: ID!) {
      serialization(id: $id) {
        id
        name
        language {
          id
        }
      }
    }
    QUERY
  end

  let!(:serialization) { create(:serialization) }

  it_behaves_like 'a GraphQL query', 'serialization' do
    let(:variables_existent) { {'id' => serialization.to_param} }
    let(:variables_not_existent) { {'id' => "bad-#{serialization.to_param}"} }
    let(:expectation_signed_in_existent) do
      match('data' => {'serialization' => include(
        'id' => serialization.to_param,
        'name' => serialization.name,
        'language' => include('id' => serialization.language.to_param)
      )})
    end
    let(:expectation_signed_in_not_existent) do
      match('data' => {'serialization' => nil})
    end
    let(:expectation_not_signed_in_existent) do
      expectation_signed_in_existent
    end
    let(:expectation_not_signed_in_not_existent) do
      expectation_signed_in_not_existent
    end
  end
end
