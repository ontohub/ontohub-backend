# frozen_string_literal: true

module Mutations
  # GraphQL mutation to create a new repository
  class CreateRepositoryMutation
    def call(_root, arguments, _context)
      params = arguments[:data].to_h.
        merge(url_path_method: ModelURLPath.repository)
      params['owner'] = OrganizationalUnit.find(slug: params['owner'])
      params['public_access'] = params.delete('visibility') == 'public'
      repository = RepositoryCompound.new(params)
      repository.save
      repository
    end
  end
end
