# frozen_string_literal: true

Types::LanguageMappingType = GraphQL::ObjectType.define do
  name 'LanguageMapping'
  description 'A mapping between two languages'

  field :id, !types.ID do
    description 'The ID of this LanguageMapping'
  end

  field :source, !Types::LanguageType do
    description 'The source language'
  end

  field :target, !Types::LanguageType do
    description 'The target language'
  end
end
