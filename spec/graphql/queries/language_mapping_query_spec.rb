# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'LanguageMapping query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: Int!) {
      languageMapping(id: $id) {
        id
        source {
          id
        }
        target {
          id
        }
      }
    }
    QUERY
  end

  let!(:language_mapping) { create(:language_mapping) }

  it_behaves_like 'a GraphQL query', 'languageMapping' do
    let(:variables_existent) { {'id' => language_mapping.pk} }
    let(:variables_not_existent) { {'id' => 0} }
    let(:expectation_signed_in_existent) do
      match('data' => {'languageMapping' => include(
        'id' => language_mapping.pk,
        'source' => include('id' => language_mapping.source.to_param),
        'target' => include('id' => language_mapping.target.to_param)
      )})
    end
    let(:expectation_signed_in_not_existent) do
      match('data' => {'languageMapping' => nil})
    end
    let(:expectation_not_signed_in_existent) do
      expectation_signed_in_existent
    end
    let(:expectation_not_signed_in_not_existent) do
      expectation_signed_in_not_existent
    end
  end
end
