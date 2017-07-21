# frozen_string_literal: true

module V3
  # Provides the DSL to use the Graphql API from the REST controllers
  module DSL
    # Contains Graphql options for one REST actions
    class Graphql
      attr_reader :query_string, :arguments_proc, :context_proc

      def initialize
        @arguments_proc = proc {}
      end

      def query(query_string)
        @query_string = query_string
      end

      def arguments(&block)
        @arguments_proc = block
      end

      def context(&block)
        @context_proc = block
      end
    end

    def context(&block)
      @@context_proc = block
    end

    # rubocop:disable Metrics/MethodLength
    def graphql(method_name, &block)
      # rubocop:enable Metrics/MethodLength
      obj = Graphql.new
      obj.instance_eval(&block)
      send(:define_method, method_name) do
        variables = instance_eval(&obj.arguments_proc)
        context = instance_eval(&obj.context_proc || @@context_proc)

        result = OntohubBackendSchema.execute(
          obj.query_string,
          variables: variables || {},
          context: context || {}
        )
        render json: result
      end
    end
  end
end
