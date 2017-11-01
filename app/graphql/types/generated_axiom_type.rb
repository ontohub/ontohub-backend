# frozen_string_literal: true

Types::GeneratedAxiomType = GraphQL::ObjectType.define do
  name 'GeneratedAxiom'
  description 'An that has been generated during reasoning'

  field :id, !types.Int do
    description 'The ID of the GeneratedAxiom'
  end

  field :text, !types.String do
    description 'The definitional text'
  end

  field :reasoningAttempt, !Types::ReasoningAttemptType do
    description 'The ReasoningAttempt in which this axiom has been generated'
    property :reasoning_attempt
  end
end
