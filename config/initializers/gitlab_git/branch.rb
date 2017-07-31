# frozen_string_literal: true

module Gitlab
  module Git
    # Extension to make the GraphQL type Types::Git::ReferenceType work
    class Branch
      def kind
        # :nocov:
        'Git::Branch'
        # :nocov:
      end
    end
  end
end
