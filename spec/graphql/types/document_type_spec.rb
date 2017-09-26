# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'a document in GraphQL' do
  let(:type) { OntohubBackendSchema.types['Document'] }
  let(:arguments) { {} }
  let(:resolved_field) { field.resolve(subject, arguments, {}) }

  before do
    create(:document_link, source: subject)
    create(:document_link, target: subject)
  end

  %w(locId documentLinks documentLinksBySource documentLinksByTarget).
    each do |field_name|
    context "#{field_name} field" do
      let(:field) { type.get_field(field_name) }

      it 'resolves the field correctly' do
        expect(resolved_field).to eq(subject.public_send(field_name.underscore))
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
