# frozen_string_literal: true

module Bringit
  # Extension to make the GraphQL type Types::Git::ReferenceType work
  class Tag
    def kind
      # :nocov:
      'Git::Tag'
      # :nocov:
    end
  end
end
