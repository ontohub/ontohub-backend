# frozen_string_literal: true

Types::OMSType = GraphQL::ObjectType.define do
  name 'OMS'
  description 'An Ontology, Model or Specification (OMS)'
  implements Types::LocIdBaseType, inherit: true

  field :document, !Types::DocumentType do
    description 'The Document containing this OMS'
  end

  field :language, !Types::LanguageType do
    description 'The Language of this OMS'
  end

  field :logic, !Types::LogicType do
    description 'The Logic of this OMS'
  end

  field :signature, !Types::SignatureType do
    description 'The Signature of this OMS'
  end

  field :serialization, Types::SerializationType do
    description 'The Serialization of this OMS'
  end

  field :normalForm, Types::OMSType do
    description 'The normal form of this OMS'
    property :normal_form
  end

  field :normalFormSignatureMorphism, Types::SignatureMorphismType do
    description 'The signature morphism leading to the normal form'
    property :normal_form_signature_morphism
  end

  field :freeNormalForm, Types::OMSType do
    description 'The free normal form of this OMS'
    property :free_normal_form
  end

  field :freeNormalFormSignatureMorphism, Types::SignatureMorphismType do
    description 'The signature morphism leading to the free normal form'
    property :free_normal_form_signature_morphism
  end

  field :conservativityStatus, !Types::ConservativityStatusType do
    description 'The conservativity status of this OMS'
    property :conservativity_status
  end

  field :nameFileRange, Types::FileRangeType do
    description 'The Range of the name of this OMS'
    property :name_file_range
  end

  field :displayName, !types.String do
    description 'The human-friendly name of this OMS'
    property :display_name
  end

  field :name, !types.String do
    description 'The technical name of this OMS'
  end

  field :nameExtension, !types.String do
    description 'The technical name extension of this OMS'
    property :name_extension
  end

  field :nameExtensionIndex, !types.Int do
    description 'The index of this OMS by the name+extension'
    property :name_extension_index
  end

  field :description, types.String do
    description 'The description of this OMS'
  end

  field :origin, !Types::OMSOriginEnum do
    description 'The origin of this OMS'
  end

  field :labelHasHiding, !types.Boolean do
    description 'Flag indicating whether this OMS uses hiding'
    property :label_has_hiding
  end

  field :labelHasFree, !types.Boolean do
    description 'Flag indicating whether this OMS uses freeness'
    property :label_has_free
  end

  field :mappings, !types[Types::MappingType] do
    description 'Mappings of which this OMS is the the source or the target'

    argument :origin, Types::LinkOriginEnum do
      description <<~DESCRIPTION
        Specifies which end of the link the current OMS is
      DESCRIPTION
      default_value 'any'
    end

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resolve(lambda do |oms, arguments, _context|
      case arguments['origin']
      when 'source'
        oms.mappings_by_source_dataset
      when 'target'
        oms.mappings_by_target_dataset
      else
        oms.mappings_dataset
      end.order(Sequel[:loc_id_bases][:loc_id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :consistencyCheckAttempts,
    !types[!Types::ConsistencyCheckAttemptType] do
    description "The attempts to check this OMS's consistency"

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resolve(lambda do |oms, arguments, _context|
      oms.consistency_check_attempts_dataset.
        order(Sequel[:reasoning_attempts][:id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :sentences, !types[!Types::SentenceType] do
    description 'All sentneces in this OMS'

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resolve(lambda do |oms, arguments, _context|
      oms.sentences_dataset.
        order(Sequel[:loc_id_bases][:loc_id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end
end
