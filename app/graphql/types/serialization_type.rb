# frozen_string_literal: true

Types::SerializationType = GraphQL::ObjectType.define do
  name 'Serialization'
  description 'A serialization of a language'

  field :id, !types.ID do
    description 'The ID of this serialization'
    property :slug
  end

  field :language, !Types::LanguageType do
    description 'The language to which this serialization belongs'
  end

  field :name, !types.String do
    description 'The name of this serialization'
  end
end
