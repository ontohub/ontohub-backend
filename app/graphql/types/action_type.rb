# frozen_string_literal: true

Types::ActionType = GraphQL::ObjectType.define do
  name 'Action'
  description 'Describes a evaluation state and contains a possible message'

  field :evaluationState, !Types::EvaluationStateEnum do
    description 'The state of evaluation'
    property :evaluation_state
  end

  field :message, types.String do
    description 'A message describing details of the state'
  end
end
