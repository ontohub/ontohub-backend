# frozen_string_literal: true

Types::ConsistencyStatusEnum = GraphQL::EnumType.define do
  name 'ConsistencyStatus'
  description 'Specifies the consistency status of an OMS'

  value 'Open', 'No concistency attempt has been finished.'
  value 'Timeout', 'The reasoner ran out of time.'
  value 'Error', 'A concistency attempt has failed.'
  value 'Consistent', 'The OMS is consistent.'
  value 'Inconsistent', 'The OMS is inconsistent.'
  value 'Contradictory', <<~CONTR
    There are concistency attempts that found a proof as well as some that found a counter example. This indicates a malfunction of the reasoning system.
  CONTR
end
