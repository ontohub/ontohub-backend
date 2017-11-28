# frozen_string_literal: true

Types::OpenConjectureType = GraphQL::ObjectType.define do
  name 'OpenConjecture'
  description 'An open (unproved) conjecture'

  implements Types::LocIdBaseType, inherit: true
  implements Types::SentenceType, inherit: true
  implements Types::ConjectureType, inherit: true
end
