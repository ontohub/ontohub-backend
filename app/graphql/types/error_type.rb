# frozen_string_literal: true

Types::ErrorType = GraphQL::ObjectType.define do
  name 'Error'
  description 'An error message'
  implements Types::DiagnosisType, inherit: true
end
