# frozen_string_literal: true

# Methods that should be in Types::LocIdBaseType, but cannot be there
# because of https://github.com/rmosolgo/graphql-ruby/issues/1067
# rubocop:disable Style/ClassAndModuleChildren
module Types::LocIdBaseMethods
  # rubocop:enable Style/ClassAndModuleChildren
  def self.get(scope)
    scope.field :locId, !scope.types.ID do
      description 'The Loc/Id of the document'
      property :loc_id
    end

    scope.field :fileVersion, !Types::FileVersionType do
      description 'The FileVersion to which this object belongs'
      property :file_version
    end
  end
end
