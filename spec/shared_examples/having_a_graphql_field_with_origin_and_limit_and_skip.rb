# frozen_string_literal: true

RSpec.shared_examples 'having a GraphQL field with '\
  'origin and limit and skip' do |field_name, default_limit = 20|
  context "#{field_name} field" do
    context 'with argument origin: any' do
      let(:arguments) { {'origin' => 'any'} }

      it_behaves_like 'having a GraphQL field with limit and skip',
        field_name, default_limit do
        let!(:available_items) { links_all }
      end
    end

    context 'with argument origin: source' do
      let(:arguments) { {'origin' => 'source'} }

      it_behaves_like 'having a GraphQL field with limit and skip',
        field_name, default_limit do
        let!(:available_items) { links_source }
      end
    end

    context 'with argument origin: target' do
      let(:arguments) { {'origin' => 'target'} }

      it_behaves_like 'having a GraphQL field with limit and skip',
        field_name, default_limit do
        let!(:available_items) { links_target }
      end
    end
  end
end
