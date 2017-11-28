# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::LanguageType do
  let(:language) { create(:language) }

  let(:type) { OntohubBackendSchema.types['Language'] }
  let(:arguments) { {} }

  context 'languageMappings field' do
    it_behaves_like 'having a GraphQL field with origin and limit and skip',
      'languageMappings' do
      let(:root) { language }
      let(:links_source) do
        create_list(:language_mapping, 21, source: language).sort_by(&:id)
      end
      let(:links_target) do
        create_list(:language_mapping, 21, target: language).sort_by(&:id)
      end
      let!(:links_all) do
        (links_source + links_target).sort_by(&:id)
      end
    end
  end

  it_behaves_like 'having a GraphQL field with limit and skip', 'logics' do
    let(:root) { language }
    let!(:available_items) do
      create_list(:logic, 21, language: language).sort_by(&:slug)
    end
  end
end
