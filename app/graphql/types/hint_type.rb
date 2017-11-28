# frozen_string_literal: true

Types::HintType = GraphQL::ObjectType.define do
  name 'Hint'
  description 'A hint'
  implements Types::DiagnosisType, inherit: true
end
