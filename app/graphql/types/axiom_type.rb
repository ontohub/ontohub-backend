# frozen_string_literal: true

Types::AxiomType = GraphQL::ObjectType.define do
  name 'Axiom'
  description 'An axiom'

  implements Types::LocIdBaseType, inherit: true
  implements Types::SentenceType, inherit: true
end
