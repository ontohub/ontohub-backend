# frozen_string_literal: true

Types::Git::FileEncodingEnum = GraphQL::EnumType.define do
  name 'FileEncoding'
  description 'Possible values for file encodings'

  value 'base64'
  value 'plain'
end
