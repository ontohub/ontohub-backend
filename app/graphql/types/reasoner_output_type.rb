# frozen_string_literal: true

Types::ReasonerOutputType = GraphQL::ObjectType.define do
  name 'ReasonerOutput'
  description 'The output of a Reasoner'

  field :reasoningAttempt, !Types::ReasoningAttemptType do
    description 'The ReasoningAttempt in which this axiom has been generated'
    property :reasoning_attempt
  end

  field :reasoner, !Types::ReasonerType do
    description 'The Reasoner that produced this output'
  end

  field :text, !types.String do
    description 'The actual output'
  end
end
