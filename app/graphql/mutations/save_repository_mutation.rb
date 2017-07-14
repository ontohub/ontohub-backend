# frozen_string_literal: true

module Mutations
  # GraphQL mutation to update an repository
  class SaveRepositoryMutation
    def call(repository, arguments, _context)
      params = arguments[:data].to_h.compact
      params['public_access'] = params.delete('visibility') == 'public'
      params['description'] = nil if params['description'].empty?
      repository.update(params)
      repository
    end
  end
end
