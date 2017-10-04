# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a document in GraphQL' do
  let(:type) { OntohubBackendSchema.types['Document'] }
  let(:arguments) { {} }
  let(:resolved_field) { field.resolve(subject, arguments, {}) }

  before do
    create(:document_link, source: subject)
    create(:document_link, target: subject)
  end

  context 'locId field' do
    let(:field) { type.get_field('locId') }

    it 'resolves the field correctly' do
      expect(resolved_field).to eq(subject.loc_id)
    end
  end

  context 'documentLinks field' do
    let(:field) { type.get_field('documentLinks') }

    context 'without arguments' do
      it 'resolves the field correctly' do
        expect(resolved_field).to eq(subject.document_links)
      end
    end

    context 'with argument origin: source' do
      let(:arguments) { {'origin' => 'any'} }
      it 'resolves the field correctly' do
        expect(resolved_field).to eq(subject.document_links)
      end
    end

    context 'with argument origin: source' do
      let(:arguments) { {'origin' => 'source'} }
      it 'resolves the field correctly' do
        expect(resolved_field).to eq(subject.document_links_by_source)
      end
    end

    context 'with argument origin: target' do
      let(:arguments) { {'origin' => 'target'} }
      it 'resolves the field correctly' do
        expect(resolved_field).to eq(subject.document_links_by_target)
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
