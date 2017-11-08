# frozen_string_literal: true

module Instrumenters
  # Rescues Sequel::ValidationFailed errors and raises
  # GraphQL::ExecutionError instead
  class NotFoundUnlessInstrumenter
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def instrument(_type, field)
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
      query = field.metadata[:not_found_unless]
      return field unless query

      old_resolve = field.resolve_proc
      field.redefine do
        resolve(lambda do |root, arguments, context|
          if Pundit.policy!(context[:current_user], root).public_send(query.to_s + '?')
            return old_resolve.call(root, arguments, context) 
          end

          context.add_error(GraphQL::ExecutionError.new('resource not found'))
          nil
        end)
      end
    end
  end
end

GraphQL::Field.accepts_definitions(
  not_found_unless: 
    GraphQL::Define::InstanceDefinable::AssignMetadataKey.new(:not_found_unless)
)
