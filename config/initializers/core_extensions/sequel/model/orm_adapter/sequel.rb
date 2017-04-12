# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
class Sequel::Model
  # This is monkey-patching the get method to allow for class table inheritance.
  # orm_adapter-sequel's development is stale.
  class OrmAdapter < ::OrmAdapter::Base
    def get(id)
      column = "#{klass.table_name}__#{klass.primary_key}"
      klass.find(wrap_key(column.to_sym => id))
    end
  end
end
