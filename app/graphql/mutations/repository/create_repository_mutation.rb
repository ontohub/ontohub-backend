# frozen_string_literal: true

module Mutations
  module Repository
    CreateRepositoryMutation = GraphQL::Field.define do
      type Types::RepositoryType
      description 'Creates a new repository'

      argument :data, !Types::Repository::NewType do
        description 'The parameters of the new repository'
      end

      resource!(lambda do |_root, arguments, _context|
        OrganizationalUnit.first(slug: arguments['data']['owner'])
      end)

      authorize!(lambda do |owner, _arguments, context|
        RepositoryPolicy.new(context[:current_user], nil).create?(owner)
      end)

      resolve CreateRepositoryResolver.new
    end

    # GraphQL mutation to create a new repository
    class CreateRepositoryResolver
      def call(owner, arguments, _context)
        params = arguments[:data].to_h
        params['owner'] = owner
        params['public_access'] = params.delete('visibility') == 'public'
        repository = RepositoryCompound.new(params)
        repository.save
        IndexingJob.
          perform_later('class' => 'Repository', 'id' => repository.id)
        repository
      end
    end
  end
end
