# frozen_string_literal: true

module Rest
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
      define_method(:context_proc) { block }
      protected :context_proc
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def graphql(method_name, &block)
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
      obj = Graphql.new
      obj.instance_eval(&block)
      send(:define_method, method_name) do
        variables = instance_eval(&obj.arguments_proc) || {}
        global_context = instance_eval(&context_proc || proc { {} })
        local_context = instance_eval(&obj.context_proc || proc { {} })
        context = global_context.merge(local_context)

        result = OntohubBackendSchema.execute(
          obj.query_string,
          variables: variables || {},
          context: context
        )
        render json: result
      end
    end
  end
end
