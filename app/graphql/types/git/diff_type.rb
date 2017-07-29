# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Types::Git::DiffType = GraphQL::ObjectType.define do
  # rubocop:enable Metrics/BlockLength
  name 'Diff'
  description 'Change of a file'

  field :aMode, !types.String do
    description 'The file mode in the old state'
    property :a_mode
  end
  field :bMode, !types.String do
    description 'The file mode in the new state'
    property :b_mode
  end

  field :diff, !types.String do
    description 'The actual diff'
  end

  field :lineCount, !types.Int do
    description 'The number of changed lines'
    property :line_count
  end

  field :newPath, !types.String do
    description 'The new path of the file'
    property :new_path
  end

  field :oldPath, !types.String do
    description 'The old path of the file'
    property :old_path
  end

  field :newFile, !types.Boolean do
    description 'True if the file was added'
    property :new_file
  end

  field :renamedFile, !types.Boolean do
    description 'True if the file was renamed'
    property :renamed_file
  end

  field :deletedFile, !types.Boolean do
    description 'True if the file was deleted'
    property :deleted_file
  end
end
