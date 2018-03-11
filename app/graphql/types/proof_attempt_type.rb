# frozen_string_literal: true

Types::ProofAttemptType = GraphQL::ObjectType.define do
  name 'ProofAttempt'
  description 'An attempt to prove a conjecture'

  implements Types::ReasoningAttemptType, inherit: true

  field :proofStatus, !Types::ProofStatusEnum do
    description 'The proof status of this ProofAttempt'
    property :proof_status
  end

  field :conjecture, !Types::ConjectureType do
    description 'The conjecture of interest'
  end
end
