# frozen_string_literal: true

module GraphQL
  class Field
    def default_arguments(args = {})
      arguments.transform_values(&:default_value).merge(args)
    end
  end
end

Dir[Rails.root.join('app/graphql/instrumenters/*.rb')].each { |f| require f }
