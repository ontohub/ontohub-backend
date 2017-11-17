# frozen_string_literal: true

module Mutations
  module Repository
    module Git
      CommitMutation = GraphQL::Field.define do
        type Types::Git::CommitType
        description 'Creates a new commit'

        argument :repositoryId, !types.ID do
          description 'The repository to create the branch in'
        end

        argument :newCommit, !Types::Git::Commit::NewType do
          description 'The information of the commit'
        end

        resource!(lambda do |_root, arguments, _context|
          RepositoryCompound.first(slug: arguments['repositoryId'])
        end)

        not_found_unless :show

        authorize! :write, policy: :repository

        resolve CreateCommitResolver.new
      end

      # GraphQL mutation to create a new branch
      class CreateCommitResolver
        def call(repository, arguments, context)
          resource = build_resource(repository, arguments, context)
          repository.git.commit(resource.save)
        end

        protected

        def build_resource(repository, arguments, context)
          MultiBlob.new(files: files(arguments),
                        previous_head_sha:
                          arguments['newCommit']['lastKnownHeadId'],
                        commit_message: arguments['newCommit']['message'],
                        branch: arguments['newCommit']['branch'],
                        repository: repository,
                        user: context[:current_user])
        end

        # rubocop:disable Metrics/MethodLength
        def files(arguments)
          # rubocop:enable Metrics/MethodLength
          # TODO: Restructure as soon as REST controllers are fully refactored
          # to use graphql. There shall be no previous_path in MultiBlob. Adjust
          # MultiBlob to use the same interface as GraphQL.
          arguments['newCommit']['files'].map do |file|
            file = file.to_h.symbolize_keys
            if file[:action] == 'rename' ||
               (file[:action] == 'update' && file[:new_path])
              previous_path = file.delete(:path)
              new_path = file.delete(:new_path)
              file[:path] = new_path
              file[:previous_path] = previous_path
            end
            file
          end
        end
      end
    end
  end
end
