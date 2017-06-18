# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OntohubBackendSchema do
  let(:current_schema) { GraphQL::Schema::Printer.print_schema(OntohubBackendSchema) }

  describe 'Schema' do
    it 'matches the generated schema' do
      File.open(Rails.root.join('spec/support/schema.graphql'), 'r') do |f|
        expect(current_schema).to eq(f.read)
      end
    end
  end
end
