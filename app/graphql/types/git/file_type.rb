# frozen_string_literal: true

Types::Git::FileType = GraphQL::ObjectType.define do
  name 'File'
  description 'A file of a repository'

  field :name, !types.String do
    description 'The name of the file'
  end

  field :path, !types.String do
    description 'The path of the file'
  end

  field :size, !types.Int do
    description 'The size in bytes'
  end

  field :loaded_size, !types.Int do
    description 'The bumber of bytes that has been loaded of the content'
  end

  field :content, !types.String do
    description 'The content of the file'
  end

  field :encoding, !Types::Git::FileEncodingEnum do
    description 'The encoding of the content'
  end
end
