# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::DocumentLinkType do
  let(:type) { OntohubBackendSchema.types['DocumentLink'] }
  let(:arguments) { {} }
  let(:resolved_field) { field.resolve(subject, arguments, {}) }

  subject { create(:document_link) }

  %w(source target).each do |field_name|
    context "#{field_name} field" do
      let(:field) { type.get_field(field_name) }

      it 'resolves the field correctly' do
        expect(resolved_field).to eq(subject.public_send(field_name.underscore))
      end
    end
  end
end
