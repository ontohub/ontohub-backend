# frozen_string_literal: true

module Gitlab
  module Git
    # Extension to make the GraphQL type Types::Git::ReferenceType work
    class Tag
      def kind
        'Git::Tag'
      end
    end
  end
end
