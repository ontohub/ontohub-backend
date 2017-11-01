# frozen_string_literal: true

Types::LogicMappingType = GraphQL::ObjectType.define do
  name 'LogicMapping'
  description 'A mapping between two logics'

  field :id, !types.ID do
    description 'The ID of this LogicMapping'
    property :slug
  end

  field :languageMapping, !Types::LanguageMappingType do
    description 'The LanguageMapping to which this LogicMapping belongs'
    property :language_mapping
  end

  field :source, !Types::LogicType do
    description 'The source logic'
  end

  field :target, !Types::LogicType do
    description 'The target logic'
  end
end
