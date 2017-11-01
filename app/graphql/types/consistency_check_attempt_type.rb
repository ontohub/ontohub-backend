# frozen_string_literal: true

Types::ConsistencyCheckAttemptType = GraphQL::ObjectType.define do
  name 'ConsistencyCheckAttempt'
  description 'An attempt to check consistency of an OMS'

  implements Types::ReasoningAttemptType, inherit: true

  field :oms, !Types::OMSType do
    description 'The OMS of interest'
  end
end
