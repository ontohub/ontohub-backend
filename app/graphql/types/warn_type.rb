# frozen_string_literal: true

Types::WarnType = GraphQL::ObjectType.define do
  name 'Warn'
  description 'A warning'
  implements Types::DiagnosisType, inherit: true
end
