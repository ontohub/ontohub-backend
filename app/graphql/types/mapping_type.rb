# frozen_string_literal: true

Types::MappingType = GraphQL::ObjectType.define do
  name 'Mapping'
  description 'A mapping between two OMS'

  implements Types::LocIdBaseType, inherit: true

  field :source, !Types::OMSType do
    description 'The source of the Mapping'
  end

  field :target, !Types::OMSType do
    description 'The target of the Mapping'
  end

  field :signatureMorphism, !Types::SignatureMorphismType do
    description 'The SignatureMorphism that this Mapping uses'
    property :signature_morphism
  end

  field :conservativityStatus, !Types::ConservativityStatusType do
    description 'The ConservativityStatus of this Mapping'
    property :conservativity_status
  end

  field :freenessParameterOMS, Types::OMSType do
    description "The OMS of the Mapping's freeness parameter"
    property :freeness_parameter_oms
  end

  field :freenessParameterLanguage, Types::LanguageType do
    description "The Language of the Mapping's freeness parameter"
    property :freeness_parameter_language
  end

  field :displayName, !types.String do
    description 'The human-friendly name of this Mapping'
    property :display_name
  end

  field :name, !types.String do
    description 'The technical name of this Mapping'
  end

  field :origin, !Types::MappingOriginEnum do
    description 'The origin of this Mapping'
  end

  field :type, !Types::MappingTypeEnum do
    description 'The type of this Mapping'
  end

  field :pending, !types.Boolean do
    description 'True if there are open proofs in this Mapping'
  end
end
