# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::ConjectureType do
  let(:conjecture) { create(:open_conjecture) }

  let(:type) { OntohubBackendSchema.types['Conjecture'] }
  let(:arguments) { {} }

  it_behaves_like 'having a GraphQL field with limit and skip',
    'proofAttempts' do
    let(:root) { conjecture }
    let!(:available_items) do
      create_list(:proof_attempt, 21, conjecture: conjecture).sort_by(&:id)
    end
  end
end
