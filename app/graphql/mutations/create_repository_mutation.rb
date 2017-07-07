# frozen_string_literal: true

module Mutations
  # GraphQL mutation to create a new repository
  class CreateRepositoryMutation
    def call(_root, arguments, context)
      params = arguments[:data].to_h.
        merge(url_path_method: ModelURLPath.repository)
      params['owner'] = OrganizationalUnit.find(slug: params['owner'])
      params['public_access'] = params['visibility'] == 'public'
      params.delete('visibility')
      repository = RepositoryCompound.new(params)
      repository.save
      repository
    end
  end
end
