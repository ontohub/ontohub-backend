# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProofAttemptPolicy do
  let(:reasoning_attempt) { create(:proof_attempt) }
  let(:file_version) { reasoning_attempt.conjecture.file_version }
  it_behaves_like 'a ReasoningAttemptPolicy'
end
