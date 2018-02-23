# frozen_string_literal: true

Types::Git::UpdatedRefType = GraphQL::InputObjectType.define do
  name 'UpdatedRef'
  description 'Updated Git Ref'

  argument :ref, !types.ID do
    description 'The name of the ref that was updated'
  end

  argument :before, types.ID do
    description 'The (sha hash) of the ref before the update'
  end

  argument :after, types.ID do
    description 'The (sha hash) of the ref after the update'
  end
end
