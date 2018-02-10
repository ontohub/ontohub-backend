# frozen_string_literal: true

module Mutations
  module Repository
    module Git
      UpdateRefsMutation = GraphQL::Field.define do
        type !types.Boolean
        description 'Processes a git push. Can only be called by the GitShell.'

        argument :repositoryId, !types.ID do
          description 'The repository to create the branch in'
        end

        argument :keyId, !types.Int do
          description 'The ID of the public key that was used to push'
        end

        argument :updatedRefs, !types[!Types::Git::UpdatedRefType] do
          description 'The refs that have been updated'
        end

        resource(lambda do |_root, arguments, _context|
          user = PublicKey.first(id: arguments[:keyId])&.user
          repository = ::Repository.first(slug: arguments[:repositoryId])
          {user: user, repository: repository}
        end)

        authorize(lambda do |_data, _arguments, context|
          GitShellPolicy.new(context[:current_user]).authorize?
        end)

        resolve UpdateRefsResolver.new
      end

      # GraphQL mutation to create a new branch
      class UpdateRefsResolver
        # rubocop:disable Metrics/MethodLength
        def call(data, arguments, _context)
          # rubocop:enable Metrics/MethodLength
          updated_refs = arguments[:updatedRefs].to_a.map(&:to_h)
          RefsUpdater.
            new(data[:user], data[:repository], updated_refs).call
          true
        rescue StandardError => e
          message = <<~MESSAGE
            UpdateRefsMutation: Failed to update refs.
              arguments: #{arguments.inspect}
              backtrace:
                #{e.backtrace.join("\n    ")}
          MESSAGE
          Rails.logger.error(message)
          false
        end
      end
    end
  end
end
