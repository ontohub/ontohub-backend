# frozen_string_literal: true

RSpec.shared_examples 'a GraphQL query' do |data_path, check_existence = true|
  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: _real_context,
      variables: _real_variables
    ).to_h
  end

  shared_examples 'a valid query' do
    context 'on an existing object' do
      let(:_real_variables) { variables_existent }
      it 'returns the object fields' do
        expect(result).to _real_expectation_existent
      end
    end

    if check_existence
      context 'on a non-existant object' do
        let(:_real_variables) { variables_not_existent }
        it 'returns null' do
          expect(result).to _real_expectation_not_existent
        end
      end
    end
  end

  context Array(data_path).join('/') do
    let(:_real_context) { context.merge(current_user: real_current_user) }

    context 'when signed in' do
      let(:real_current_user) do
        if defined?(current_user)
          current_user
        else
          create(:user)
        end
      end

      include_examples 'a valid query' do
        let(:_real_expectation_existent) { expectation_signed_in_existent }
        let(:_real_expectation_not_existent) do
          expectation_signed_in_not_existent
        end
      end
    end

    context 'when not signed in' do
      let(:real_current_user) { nil }

      include_examples 'a valid query' do
        let(:_real_expectation_existent) { expectation_not_signed_in_existent }
        let(:_real_expectation_not_existent) do
          expectation_not_signed_in_not_existent
        end
      end
    end
  end
end
