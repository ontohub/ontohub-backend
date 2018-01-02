# frozen_string_literal: true

module Mutations
  module Repository
    CloneRepositoryMutation = GraphQL::Field.define do
      type Types::RepositoryType
      description 'Clones a repository from a remote server'

      argument :data, !Types::Repository::NewType do
        description 'The parameters of the new repository'
      end

      argument :remoteAddress, !types.String do
        description 'The address of a remote repository'
      end

      argument :remoteType, !Types::Repository::RepositoryRemoteTypeEnum do
        description 'The type of the cloned repository'
      end

      argument :urlMappings, !types[!Types::Repository::NewUrlMappingType] do
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

    # GraphQL mutation to clone a new repository
    class CloneRepositoryResolver
      def call(_owner, arguments, context)
        params = prepare_params(arguments)

        if Bringit::Wrapper.valid_remote?(params['remote_address'])
          create_repository(arguments, params)
        else
          add_invalid_remote_error(context, params['remote_address'])
        end
      end

      def create_repository(arguments, params)
        repository = ::Repository.create(params)
        arguments['urlMappings'].each do |url_mapping|
          UrlMapping.create(repository_id: repository.id,
                            source: url_mapping['source'],
                            target: url_mapping['target'])
        end
        RepositoryCloningJob.perform_later(repository.to_param)
        repository
      end

      def prepare_params(arguments)
        params = arguments[:data].to_h
        params['owner'] = OrganizationalUnit.first(slug: params['owner'])
        params['public_access'] = params.delete('visibility') == 'public'
        params['remote_address'] = arguments['remoteAddress']
        params['remote_type'] = arguments['remoteType']
        params
      end

      def add_invalid_remote_error(context, remote_address)
        error = <<~ERROR
          remote_address: "#{remote_address}" is not a git or svn repository
        ERROR
        context.add_error(GraphQL::ExecutionError.new(error))
        nil
      end
    end
  end
end
