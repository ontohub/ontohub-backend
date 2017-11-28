# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProofAttemptPolicy do
  let(:reasoning_attempt) { create(:consistency_check_attempt) }
  let(:file_version) { reasoning_attempt.oms.file_version }
  it_behaves_like 'a ReasoningAttemptPolicy'
end
