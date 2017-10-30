# frozen_string_literal: true

# Allows specifying a `resource` proc on fields, whose result will be passed
# to the resolve function of the field as the first argument.
module Instrumenters
  # Allows specifying a `resource` proc on fields, whose result will be passed
  # to the resolve function of the field as the first argument.
  # Authorization should be performed after this step, so the object can be
  # properly authorized
  class ResourceInstrumenter
    def instrument(_type, field)
      old_resolve = field.resolve_proc
      resource_meta = field.metadata[:resource]
      return field unless resource_meta

      resource_proc = resource_meta[:proc]
      new_resolve = resolve_proc(old_resolve,
                                resource_proc,
                                resource_meta[:raise_on_nil])
      field.redefine { resolve new_resolve }
    end

    protected

    def resolve_proc(old_resolve, resource_proc, raise_on_nil)
      lambda do |root, arguments, context|
        resource = resource_proc.call(root, arguments, context)
        if resource || !raise_on_nil
          old_resolve.call(resource, arguments, context)
        else
          context.add_error(GraphQL::ExecutionError.new('resource not found'))
        end
      end
    end
  end

  def self.assign_resource(raise_on_nil)
    lambda do |defn, proc|
      opts = {raise_on_nil: raise_on_nil, proc: proc}
      GraphQL::Define::InstanceDefinable::AssignMetadataKey.new(:resource).
        call(defn, opts)
    end
  end
end

GraphQL::Field.accepts_definitions(
  resource: Instrumenters.assign_resource(false),
  resource!: Instrumenters.assign_resource(true)
)
