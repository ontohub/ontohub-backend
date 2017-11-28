# frozen_string_literal: true

Types::CounterTheoremType = GraphQL::ObjectType.define do
  name 'CounterTheorem'
  description 'A counter-theorem (disproved conjecture)'

  implements Types::LocIdBaseType, inherit: true
  implements Types::SentenceType, inherit: true
  implements Types::ConjectureType, inherit: true
end
