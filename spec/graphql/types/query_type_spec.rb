# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  let(:type) { OntohubBackendSchema.types['Query'] }
  let(:arguments) { {} }

  it_behaves_like 'having a GraphQL field for an object', 'language' do
    let(:language) { create(:language) }

    let(:root) { nil }
    let(:good_arguments) { {'id' => language.to_param} }
    let(:bad_arguments) { {'id' => "bad-#{language.to_param}"} }
    let(:expected_object) { language }
  end

  it_behaves_like 'having a GraphQL field for an object', 'languageMapping' do
    let(:language_mapping) { create(:language_mapping) }

    let(:root) { nil }
    let(:good_arguments) { {'id' => language_mapping.to_param} }
    let(:bad_arguments) { {'id' => 0} }
    let(:expected_object) { language_mapping }
  end

  it_behaves_like 'having a GraphQL field for an object', 'logic' do
    let(:logic) { create(:logic) }

    let(:root) { nil }
    let(:good_arguments) { {'id' => logic.to_param} }
    let(:bad_arguments) { {'id' => "bad-#{logic.to_param}"} }
    let(:expected_object) { logic }
  end

  it_behaves_like 'having a GraphQL field for an object', 'logicMapping' do
    let(:logic_mapping) { create(:logic_mapping) }

    let(:root) { nil }
    let(:good_arguments) { {'id' => logic_mapping.to_param} }
    let(:bad_arguments) { {'id' => "bad-#{logic_mapping.to_param}"} }
    let(:expected_object) { logic_mapping }
  end

  it_behaves_like 'having a GraphQL field for an object', 'serialization' do
    let(:serialization) { create(:serialization) }

    let(:root) { nil }
    let(:good_arguments) { {'id' => serialization.to_param} }
    let(:bad_arguments) { {'id' => "bad-#{serialization.to_param}"} }
    let(:expected_object) { serialization }
  end

  it_behaves_like 'having a GraphQL field for an object', 'signatureMorphism' do
    let(:signature_morphism) { create(:signature_morphism) }

    let(:root) { nil }
    let(:good_arguments) { {'id' => signature_morphism.to_param} }
    let(:bad_arguments) { {'id' => 0} }
    let(:expected_object) { signature_morphism }
  end
end
