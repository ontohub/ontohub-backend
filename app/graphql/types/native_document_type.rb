# frozen_string_literal: true

Types::NativeDocumentType = GraphQL::ObjectType.define do
  name 'NativeDocument'
  description 'A NativeDocument is a container for exactly one OMS'

  implements Types::LocIdBaseType, inherit: true
  implements Types::DocumentType, inherit: true

  field :oms, !Types::OMSType do
    description 'The OMS in this NativeDocument'
  end
end
