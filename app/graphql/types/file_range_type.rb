# frozen_string_literal: true

Types::FileRangeType = GraphQL::ObjectType.define do
  name 'FileRange'
  description 'Positional information of a text element in a file'

  field :path, !types.String do
    description 'The file path'
  end

  field :startLine, !types.Int do
    description "The line of the text element's beginning"
    property :start_line
  end

  field :startColumn, !types.Int do
    description "The column of the text element's beginning"
    property :start_column
  end

  field :endLine, !types.Int do
    description "The line of the text element's end"
    property :end_line
  end

  field :endColumn, !types.Int do
    description "The column of the text element's end"
    property :end_column
  end
end
