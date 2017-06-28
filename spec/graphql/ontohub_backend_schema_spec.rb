# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OntohubBackendSchema do
  let(:schema) { OntohubBackendSchema }

  let(:current_schema) do
    GraphQL::Schema::Printer.print_schema(schema)
  end

  let(:types) do
    schema.types.to_h.reject { |k, _| k.starts_with?('__') }.values
  end

  let(:fields) do
    types.map { |type| schema.get_fields(type).values }.flatten
  end

  let(:arguments) do
    field_args = fields.map { |field| field.arguments.values }
    type_args = types.
      select { |type| type.respond_to?(:arguments) }.
      map { |type| type.arguments.values }
    (field_args + type_args).flatten
  end

  let(:saved_schema) do
    File.read(Rails.root.join('spec/support/schema.graphql')).strip
  end

  it 'matches the generated schema' do
    expect(current_schema).to eq(saved_schema)
  end

  it 'has documentation strings for all types' do
    doc_strings = types.map(&:description)
    expect(doc_strings).to all(be_truthy)
  end

  it 'has documentation strings for all fields' do
    doc_strings = fields.map(&:description)
    expect(doc_strings).to all(be_truthy)
  end

  it 'has documentation strings for all arguments' do
    doc_strings = arguments.map(&:description)
    expect(doc_strings).to all(be_truthy)
  end
end
