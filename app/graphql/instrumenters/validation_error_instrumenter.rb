# frozen_string_literal: true

module Instrumenters
  # Rescues Sequel::ValidationFailed errors and raises
  # GraphQL::ExecutionError instead
  class ValidationErrorInstrumenter
    def instrument(_type, field)
      old_resolve = field.resolve_proc
      field.redefine do
        resolve(lambda do |obj, args, ctx|
          begin
            old_resolve.call(obj, args, ctx)
          rescue Sequel::ValidationFailed => error
            ctx.add_error(GraphQL::ExecutionError.new(error.message))
          end
        end)
      end
    end
  end
end
