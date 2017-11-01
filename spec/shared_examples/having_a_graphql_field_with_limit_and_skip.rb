# frozen_string_literal: true

RSpec.shared_examples 'having a GraphQL field with '\
  'limit and skip' do |field_name, default_limit = 20|
  context "#{field_name} field" do
    let(:field) { OntohubBackendSchema.get_fields(type)[field_name] }
    let(:length) { available_items.length }

    it 'returns only the items' do
      resolved_field = field.resolve(
        root,
        field.default_arguments.merge(arguments),
        {}
      )
      upper_bound = [length, default_limit].min - 1
      expect(resolved_field).to match_array(available_items[0..upper_bound])
    end

    it 'limits the items list' do
      resolved_field = field.resolve(
        root,
        field.default_arguments('limit' => 1).merge(arguments),
        {}
      )
      expect(resolved_field).to match_array(available_items[0])
    end

    it 'skips a number of items' do
      resolved_field = field.resolve(
        root,
        field.default_arguments('skip' => 5).merge(arguments),
        {}
      )
      upper_bound = [5 + default_limit, length].min - 1
      expect(resolved_field).
        to match_array(available_items[5..upper_bound])
    end

    it 'skips a number of items and limits the list' do
      resolved_field = field.resolve(
        root,
        field.default_arguments('limit' => 5, 'skip' => 5).merge(arguments),
        {}
      )
      upper_bound = [5 + 5, length].min - 1
      expect(resolved_field).
        to match_array(available_items[5..upper_bound])
    end
  end
end
