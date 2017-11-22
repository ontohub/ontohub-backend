# frozen_string_literal: true

module Instrumenters
  # Rescues Sequel::ValidationFailed errors and raises
  # GraphQL::ExecutionError instead
  class ValidationErrorInstrumenter
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def instrument(_type, field)
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
      old_resolve = field.resolve_proc
      field.redefine do
        resolve(lambda do |root, arguments, context|
          begin
            old_resolve.call(root, arguments, context)
          rescue Sequel::ValidationFailed => error
            error.errors.each do |field_name, errors|
              errors.each do |message|
                context.add_error(
                  GraphQL::ExecutionError.new("#{field_name} #{message}")
                )
              end
            end
            nil
          rescue MultiBlob::ValidationFailed => error
            error.errors.details.each do |location, messages|
              messages.each do |message|
                public_message = "#{location} - #{message[:error]}"
                options = {}
                options[:data] = {conflicts: error.conflicts} if error.conflicts
                options.deep_stringify_keys!
                context.add_error(GraphQL::ExecutionError.new(public_message,
                                                              options: options))
              end
            end
            nil
          end
        end)
      end
    end
  end
end
