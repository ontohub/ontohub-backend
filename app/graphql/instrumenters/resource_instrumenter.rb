# frozen_string_literal: true

module Instrumenters
  # Allows specifying a `resource` proc on fields, whose result will be passed
  # to the resolve function of the field as the first argument.
  # Authorization should be performed after this step, so the object can be
  # properly authorized
  class ResourceInstrumenter
    def instrument(_type, field)
      old_resolve = field.resolve_proc
      resource_proc = field.metadata[:resource]
      new_resolve = resolve_proc(old_resolve, resource_proc)
      if resource_proc
        field.redefine do
          resolve new_resolve
        end
      else
        field
      end
    end

    def resolve_proc(old_resolve, resource_proc)
      lambda do |old_obj, args, ctx|
        obj = resource_proc.call(old_obj, args, ctx)
        if obj
          old_resolve.call(obj, args, ctx)
        else
          ctx.add_error(GraphQL::ExecutionError.new('resource not found'))
        end
      end
    end
  end
end

GraphQL::Field.accepts_definitions(
  resource: GraphQL::Define.assign_metadata_key(:resource)
)
