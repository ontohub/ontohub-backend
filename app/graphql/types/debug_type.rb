# frozen_string_literal: true

Types::DebugType = GraphQL::ObjectType.define do
  name 'Debug'
  description 'A debug message'
  implements Types::DiagnosisType, inherit: true
end
