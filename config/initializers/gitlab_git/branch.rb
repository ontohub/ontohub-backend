# frozen_string_literal: true

module Gitlab
  module Git
    # Extension to make the GraphQL type Types::Git::ReferenceType work
    class Branch
      def kind
        'Git::Branch'
      end
    end
  end
end
