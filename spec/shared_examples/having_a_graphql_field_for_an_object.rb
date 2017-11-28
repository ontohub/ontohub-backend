# frozen_string_literal: true

RSpec.shared_examples 'having a GraphQL field for an object' do |field_name|
  context "#{field_name} field" do
    let(:field) { OntohubBackendSchema.get_fields(type)[field_name] }
    let(:resolved_field) { field.resolve(root, arguments, {}) }

    context 'when it exists' do
      let(:arguments) { good_arguments }

      it 'returns the expected object' do
        expect(resolved_field).to eq(expected_object)
      end
    end

    context "when it doesn't exist" do
      let(:arguments) { bad_arguments }

      it 'returns nil' do
        expect(resolved_field).to be(nil)
      end
    end
  end
end
