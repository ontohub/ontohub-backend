# frozen_string_literal: true

Types::ProofStatusEnum = GraphQL::EnumType.define do
  name 'ProofStatus'
  description 'Specifies the proof status of a Conjecture'

  value 'OPN', 'Open: No proof attempt has been finished.'
  value 'ERR', 'Error: A proof attempt has failed.'
  value 'UNK', 'Unknown: There is no solution.'
  value 'RSO', 'ResourceOut: The reasoner ran out of time/memory.'
  value 'THM', 'Theorem: A proof was found.'
  value 'CSA', 'CounterSatisfiable: A counter example was found.'
  value 'CSAS', <<~CSAS
    CounterSatisfiable on a subset of axioms: A counter example was found but only a subset of the axioms was used. There is no conclusive result.
  CSAS
  value 'CONTR', <<~CONTR
    Contradictory: There are proof attempts that found a proof as well as some that found a counter example. This indicates a malfunction of the reasoning system.
  CONTR
end
