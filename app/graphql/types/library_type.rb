# frozen_string_literal: true

Types::LibraryType = GraphQL::ObjectType.define do
  name 'Library'
  description 'A Library is a container for any number of OMS'

  implements Types::LocIdBaseType, inherit: true
  implements Types::DocumentType, inherit: true
end
