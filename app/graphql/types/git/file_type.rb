# frozen_string_literal: true

Types::Git::FileType = GraphQL::ObjectType.define do
  name 'File'
  description 'A file of a repository'
  interfaces [Types::Git::DirectoryEntryType]

  field :size, !types.Int do
    description 'The size in bytes'
  end

  field :loadedSize, !types.Int do
    description 'The number of bytes that has been loaded of the content'
    property :loaded_size
  end

  field :content, !types.String do
    description 'The content of the file'
  end

  field :encoding, !Types::Git::FileEncodingEnum do
    description 'The encoding of the content'
  end
end
