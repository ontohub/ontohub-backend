# frozen_string_literal: true

Types::ReasoningAttemptType = GraphQL::InterfaceType.define do
  name 'ReasoningAttempt'
  description 'An attempt to prove a conjecture or check consistency of an OMS'

  field :id, !types.Int do
    description 'The ID of this ReasoningAttempt'
  end

  field :number, !types.Int do
    description 'The number of this ReasoningAttempt'
  end

  field :reasonerConfiguration, !Types::ReasonerConfigurationType do
    description 'The used ReasonerConfiguration'
    property :reasoner_configuration
  end

  field :usedReasoner, !Types::ReasonerType do
    description 'The used Reasoner'
    property :used_reasoner
  end

  field :timeTaken, types.Int do
    description 'The time it took to run the reasoner'
    property :time_taken
  end

  field :action, !Types::ActionType do
    description 'Information about the (to be) performed action'
  end

  field :generatedAxioms, !types[!Types::GeneratedAxiomType] do
    description 'Axioms that have been generated during reasoning'
    property :generated_axioms
  end

  field :reasonerOutput, Types::ReasonerOutputType do
    description 'The output of the Reasoner'
    property :reasoner_output
  end
end
