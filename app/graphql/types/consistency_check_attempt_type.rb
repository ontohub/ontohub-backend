# frozen_string_literal: true

Types::ConsistencyCheckAttemptType = GraphQL::ObjectType.define do
  name 'ConsistencyCheckAttempt'
  description 'An attempt to check consistency of an OMS'

  implements Types::ReasoningAttemptType, inherit: true

  field :consistencyStatus, !Types::ConsistencyStatusEnum do
    description 'The consistency status of this ConsistencyCheckAttempt'
    property :consistency_status
  end

  field :oms, !Types::OMSType do
    description 'The OMS of interest'
  end
end
