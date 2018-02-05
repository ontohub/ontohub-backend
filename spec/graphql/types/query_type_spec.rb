# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  let(:type) { OntohubBackendSchema.types['Query'] }
  let(:arguments) { {} }
    let(:root) { nil }

  it_behaves_like 'having a GraphQL field for an object', 'language' do
    let(:language) { create(:language) }

    let(:good_arguments) { {'id' => language.to_param} }
    let(:bad_arguments) { {'id' => "bad-#{language.to_param}"} }
    let(:expected_object) { language }
  end

  it_behaves_like 'having a GraphQL field for an object', 'languageMapping' do
    let(:language_mapping) { create(:language_mapping) }

    let(:good_arguments) { {'id' => language_mapping.to_param} }
    let(:bad_arguments) { {'id' => 0} }
    let(:expected_object) { language_mapping }
  end

  it_behaves_like 'having a GraphQL field for an object', 'logic' do
    let(:logic) { create(:logic) }

    let(:good_arguments) { {'id' => logic.to_param} }
    let(:bad_arguments) { {'id' => "bad-#{logic.to_param}"} }
    let(:expected_object) { logic }
  end

  it_behaves_like 'having a GraphQL field for an object', 'logicMapping' do
    let(:logic_mapping) { create(:logic_mapping) }

    let(:good_arguments) { {'id' => logic_mapping.to_param} }
    let(:bad_arguments) { {'id' => "bad-#{logic_mapping.to_param}"} }
    let(:expected_object) { logic_mapping }
  end

  it_behaves_like 'having a GraphQL field for an object', 'serialization' do
    let(:serialization) { create(:serialization) }

    let(:good_arguments) { {'id' => serialization.to_param} }
    let(:bad_arguments) { {'id' => "bad-#{serialization.to_param}"} }
    let(:expected_object) { serialization }
  end

  context 'gitAuthorization field' do
    let(:field_name) { 'gitAuthorization' }
    let(:field) { OntohubBackendSchema.get_fields(type)[field_name] }
    let(:resolved_field) do
      field.resolve(root, arguments, {current_user: current_user})
    end

    let(:public_key) { create(:public_key) }
    let(:repository) { create(:repository, public_access: false) }
    let!(:arguments) do
      {
        keyId: public_key.id,
        repositoryId: repository.to_param,
        action: action
      }
    end

    shared_examples 'checking the access' do
      context 'when authorized to query this field' do
        let(:current_user) { create(:git_shell_api_key) }

        context 'when the access is granted' do
          before do
            repository.add_member(public_key.user, 'admin')
          end

          it 'returns the correct result' do
            expect(resolved_field).to be(true)
          end
        end

        context 'when the access is denied' do
          let(:owner) { create(:user) }

          it 'returns the correct result' do
            expect(resolved_field).to be(false)
          end
        end
      end

      context 'when not authorized to query this field' do
        let(:current_user) { nil }
        let(:owner) { create(:user) }

        it 'returns the correct result' do
          expect(resolved_field).to be(nil)
        end
      end
    end

    context 'action: pull' do
      let(:action) { 'pull' }
      include_examples 'checking the access'
    end

    context 'action: push' do
      let(:action) { 'push' }
      include_examples 'checking the access'
    end
  end
end
