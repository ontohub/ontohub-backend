# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::LogicType do
  let(:logic) { create(:logic) }

  let(:type) { OntohubBackendSchema.types['Logic'] }
  let(:arguments) { {} }

  context 'logicMappings field' do
    it_behaves_like 'having a GraphQL field with origin and limit and skip',
      'logicMappings' do
      let(:root) { logic }
      let(:links_source) do
        create_list(:logic_mapping, 21, source: logic).sort_by(&:slug)
      end
      let(:links_target) do
        create_list(:logic_mapping, 21, target: logic).sort_by(&:slug)
      end
      let!(:links_all) do
        (links_source + links_target).sort_by(&:slug)
      end
    end
  end
end
