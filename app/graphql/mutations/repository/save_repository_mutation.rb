# frozen_string_literal: true

module Mutations
  module Repository
    SaveRepositoryMutation = GraphQL::Field.define do
      type Types::RepositoryType
      description 'Updates a repository'

      argument :id, !types.ID, as: :slug do
        description 'ID of the repository to update'
      end

      argument :data, !Types::Repository::ChangesetType do
        description 'Updated fields of the repository'
      end

      resource!(lambda do |_root, arguments, _context|
        RepositoryCompound.first(slug: arguments[:slug])
      end)

      not_found_unless :show

      authorize! :update

      resolve SaveRepositoryResolver.new
    end

    # GraphQL mutation to update an repository
    class SaveRepositoryResolver
      def call(repository, arguments, _context)
        params = arguments[:data].to_h.compact
        params['public_access'] = params.delete('visibility') == 'public'
        params['description'] = nil if params['description'].empty?
        repository.update(params)
        IndexingJob.
          perform_later('class' => 'Repository', 'id' => repository.id)
        repository
      end
    end
  end
end
