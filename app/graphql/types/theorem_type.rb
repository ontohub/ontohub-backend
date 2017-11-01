# frozen_string_literal: true

Types::TheoremType = GraphQL::ObjectType.define do
  name 'Theorem'
  description 'A theorem (proved conjecture)'

  implements Types::LocIdBaseType, inherit: true
  implements Types::SentenceType, inherit: true
  implements Types::ConjectureType, inherit: true
end
