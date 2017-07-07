# frozen_string_literal: true

module Mutations
  # GraphQL mutation to update an organization
  class SaveRepositoryMutation
    def call(repository, arguments, _context)
      params = arguments[:data].to_h.compact
      params['public_access'] = params['visibility'] == 'public'
      params['description'] = nil if params['description'].empty?
      params.delete('visibility')
      repository.update(params)
      repository
    end
  end
end
