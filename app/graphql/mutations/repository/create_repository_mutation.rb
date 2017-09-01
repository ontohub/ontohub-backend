# frozen_string_literal: true

module Mutations
  module Repository
    CreateRepositoryMutation = GraphQL::Field.define do
      type Types::RepositoryType
      description 'Creates a new repository'

      argument :data, !Types::Repository::NewType do
        description 'The parameters of the new repository'
      end

      resolve CreateRepositoryResolver.new
    end

    # GraphQL mutation to create a new repository
    class CreateRepositoryResolver
      def call(_root, arguments, _context)
        params = arguments[:data].to_h
        params['owner'] = OrganizationalUnit.find(slug: params['owner'])
        params['public_access'] = params.delete('visibility') == 'public'
        repository = RepositoryCompound.new(params)
        repository.save
        repository
      end
    end
  end
end
