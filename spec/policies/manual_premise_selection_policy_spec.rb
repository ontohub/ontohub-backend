# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ManualPremiseSelectionPolicy do
  let(:premise_selection) do
    create(:manual_premise_selection,
           reasoner_configuration: reasoner_configuration)
  end
  it_behaves_like 'a PremiseSelectionPolicy'
end
