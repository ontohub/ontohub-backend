# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::OMSType do
  let(:oms) { create(:oms) }

  let(:type) { OntohubBackendSchema.types['OMS'] }
  let(:arguments) { {} }

  context 'mappings field' do
    let(:other) { create(:oms) } # only used for speeding up the factories

    it_behaves_like 'having a GraphQL field with origin and limit and skip',
      'mappings' do
      let(:root) { oms }
      let(:links_source) do
        create_list(:mapping, 21, source: oms, target: other).sort_by(&:loc_id)
      end
      let(:links_target) do
        create_list(:mapping, 21, target: oms, source: other).sort_by(&:loc_id)
      end
      let!(:links_all) do
        (links_source + links_target).sort_by(&:loc_id)
      end
    end
  end

  it_behaves_like 'having a GraphQL field with limit and skip',
    'consistencyCheckAttempts' do
    let(:root) { oms }
    let!(:available_items) do
      create_list(:consistency_check_attempt, 21, oms: oms).sort_by(&:id)
    end
  end

  it_behaves_like 'having a GraphQL field with limit and skip', 'sentences' do
    let(:root) { oms }
    let!(:available_items) do
      create_list(:sentence, 21, oms: oms).sort_by(&:loc_id)
    end
  end
end
