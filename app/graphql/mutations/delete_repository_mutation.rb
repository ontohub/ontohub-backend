# frozen_string_literal: true

module Mutations
  # GraphQL mutation to delete a repository
  class DeleteRepositoryMutation
    def call(repository, _arguments, _context)
      repository.destroy
      true
    end
  end
end
