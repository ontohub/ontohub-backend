# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a document in GraphQL' do
  let(:type) { OntohubBackendSchema.types['Document'] }
  let(:arguments) { {} }
  let(:resolved_field) { field.resolve(subject, arguments, {}) }

  context 'locId field' do
    let(:field) { type.get_field('locId') }

    it 'resolves the field correctly' do
      expect(resolved_field).to eq(subject.loc_id)
    end
  end

  context 'documentLinks field' do
    it_behaves_like 'having a GraphQL field with origin and limit and skip',
      'documentLinks' do
      let(:root) { subject }
      let(:links_source) do
        create_list(:document_link, 21, source: subject).sort_by do |link|
          [link.source_id, link.target_id]
        end
      end
      let(:links_target) do
        create_list(:document_link, 21, target: subject).sort_by do |link|
          [link.source_id, link.target_id]
        end
      end
      let!(:links_all) do
        (links_source + links_target).sort_by do |link|
          [link.source_id, link.target_id]
        end
      end
    end
  end

  it_behaves_like 'having a GraphQL field with limit and skip', 'importedBy' do
    let(:root) { subject }
    let!(:available_items) { create_list(:document, 21).sort_by(&:loc_id) }

    before do
      available_items.each do |importer|
        create(:document_link, source: importer, target: subject)
      end
    end
  end

  it_behaves_like 'having a GraphQL field with limit and skip', 'imports' do
    let(:root) { subject }
    let!(:available_items) { create_list(:document, 21).sort_by(&:loc_id) }

    before do
      available_items.each do |importee|
        create(:document_link, source: subject, target: importee)
      end
    end
  end
end

RSpec.describe Types::NativeDocumentType do
  subject { create(:native_document) }
  it_behaves_like 'a document in GraphQL'
end

RSpec.describe Types::LibraryType do
  subject { create(:library) }
  it_behaves_like 'a document in GraphQL'
end
