# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  let(:type) { OntohubBackendSchema.types['Query'] }
  let(:arguments) { {} }

  it_behaves_like 'having a GraphQL field for an object', 'serialization' do
    let(:serialization) { create(:serialization) }

    let(:root) { nil }
    let(:good_arguments) { {'id' => serialization.to_param} }
    let(:bad_arguments) { {'id' => "bad-#{serialization.to_param}"} }
    let(:expected_object) { serialization }
  end
end
