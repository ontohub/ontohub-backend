# frozen_string_literal: true

Types::DiagnosisType = GraphQL::InterfaceType.define do
  name 'Diagnosis'
  description "A message about a file's content"

  field :fileVersion, !Types::FileVersionType do
    description 'The FileVersion which this message is about'
    property :file_version
  end

  field :fileRange, Types::FileRangeType do
    description 'The FileRange that this message is about'
    property :file_range
  end

  field :number, !types.Int do
    description 'The number of this message'
  end

  field :text, !types.String do
    description 'The actual message'
  end
end
