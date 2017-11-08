# frozen_string_literal: true

module Mutations
  module Repository
    module Git
      CreateTagMutation = GraphQL::Field.define do
        type Types::Git::TagType
        description 'Creates a new tag'

        argument :repositoryId, !types.ID do
          description 'The repository to create the tag in'
        end

        argument :name, !types.String do
          description 'The name of the tag'
        end

        argument :revision, !types.ID do
          description 'The revision the tag shall point to'
        end

        argument :annotation, types.String do
          description 'An optional annotation for the tag'
        end

        resource!(lambda do |_root, arguments, _context|
          RepositoryCompound.find(slug: arguments['repositoryId'])
        end)

        authorize! :write, policy: :repository

        not_found_unless :show

        resolve CreateTagResolver.new
      end

      # GraphQL mutation to create a new tag
      class CreateTagResolver
        def call(repository, arguments, context)
          arguments = arguments.to_h
          repository.git.create_tag(arguments['name'],
                                    arguments['revision'],
                                    annotation(arguments, context))
        rescue Gitlab::Git::Repository::InvalidRef,
               Gitlab::Git::InvalidRefName => e
          context.add_error(GraphQL::ExecutionError.new(e.message))
        end

        protected

        def annotation(arguments, context)
          return unless arguments['annotation']
          {message: arguments['annotation'],
           tagger: GitHelper.git_user(context[:current_user])}
        end
      end
    end
  end
end
