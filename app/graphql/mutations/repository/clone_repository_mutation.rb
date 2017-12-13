# frozen_string_literal: true

module Mutations
  module Repository
    CloneRepositoryMutation = GraphQL::Field.define do
      type Types::RepositoryType
      description 'Clones a repository'

      argument :data, !Types::Repository::NewType do
        description 'The parameters of the new repository'
      end

      argument :remoteAddress, !types.String do
        description 'The addres of a remote repository'
      end

      argument :remoteType, !Types::Repository::RepositoryRemoteTypeEnum do
        description 'The type of a remote repository'
      end

      argument :newUrlMappings, !types[!Types::Repository::NewUrlMappingType] do
        description <<~DESCRIPTION
          The orignial Url Mapping that are applied to the repository
        DESCRIPTION
      end

      resource!(lambda do |_root, arguments, _context|
        OrganizationalUnit.first(slug: arguments['data']['owner'])
      end)

      authorize!(lambda do |owner, _arguments, context|
        RepositoryPolicy.new(context[:current_user], nil).create?(owner)
      end)

      resolve CloneRepositoryResolver.new
    end

    # GraphQL mutation to create a new repository
    class CloneRepositoryResolver
      def call(_owner, arguments, _context)
        params = arguments[:data].to_h
        params['owner'] = OrganizationalUnit.first(slug: params['owner'])
        params['public_access'] = params.delete('visibility') == 'public'

        repository = ::Repository.create(params)
        RepositoryCloningJob.perform_later(repository.to_param)
        repository
      end
    end
  end
end
