# frozen_string_literal: true

Types::EvaluationStateEnum = GraphQL::EnumType.define do
  name 'EvaluationState'
  description 'Specifies the state of evaluation'

  value 'not_yet_enqueued',
    'The object has not yet been enqueued for evaluation'
  value 'enqueued', 'The object has been enqueued but is not yet processing'
  value 'processing', 'The object is currently in evaluation'
  value 'finished_successfully', 'The object has been evaluated successfully'
  value 'finished_unsuccessfully', 'The evaluation of this object has failed'
end
