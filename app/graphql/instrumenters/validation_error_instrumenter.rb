# frozen_string_literal: true

module Instrumenters
  # Rescues Sequel::ValidationFailed errors and raises
  # GraphQL::ExecutionError instead
  class ValidationErrorInstrumenter
    def instrument(_type, field)
      old_resolve = field.resolve_proc
      field.redefine do
        resolve(lambda do |root, arguments, context|
          begin
            old_resolve.call(root, arguments, context)
          rescue Sequel::ValidationFailed => error
            context.add_error(GraphQL::ExecutionError.new(error.message))
          end
        end)
      end
    end
  end
end
