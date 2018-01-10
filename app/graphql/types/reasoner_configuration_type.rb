# frozen_string_literal: true

Types::ReasonerConfigurationType = GraphQL::ObjectType.define do
  name 'ReasonerConfiguration'
  description 'A configuration of a Reasoner for a ReasoningAttempt'

  field :id, !types.Int do
    description 'The ID of the ReasonerConfiguration'
  end

  field :configuredReasoner, Types::ReasonerType do
    description 'The configured Reasoner'
    property :configured_reasoner
  end

  field :reasoningAttempts, !types[!Types::ReasoningAttemptType] do
    description 'The reasoningAttempts that use this configuration'
    property :reasoning_attempts
  end

  field :premiseSelections, !types[!Types::PremiseSelectionType] do
    description 'The PremiseSelections that use this configuration'
    property :premise_selections
  end

  field :timeLimit, types.Int do
    description 'How much time a reasoner can work on a reasoning task'
    property :time_limit
  end
end
