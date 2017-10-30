# frozen_string_literal: true

module Rest
  # Provides the DSL to use the Graphql API from the REST controllers
  module DSL
    # Contains Graphql options for one REST actions
    class Graphql
      attr_reader :query_string, :arguments_proc, :context_proc, :plain_proc

      def initialize
        @arguments_proc = proc {}
        @plain_proc = proc {}
      end

      def query(query_string)
        @query_string = query_string
      end

      def arguments(&block)
        @arguments_proc = block
      end

      # This is not yet used anywhere
      def context(&block)
        # :nocov:
        @context_proc = block
        # :nocov:
      end

      def plain(&block)
        @plain_proc = block
      end
    end

    # Contains helper methods for a request.
    class Request
      # rubocop:disable Metrics/MethodLength
      def self.respond_with_text?(request)
        # rubocop:enable Metrics/MethodLength
        text_index = request.accepts.index(:text)
        json_index = request.accepts.index(:json)
        if json_index && text_index
          text_index < json_index
        elsif text_index
          true
        elsif json_index
          false
        else
          false
        end
      end
    end

    def context(&block)
      define_method(:context_proc) { block }
      protected :context_proc
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity
    def graphql(method_name, &block)
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity
      obj = Graphql.new
      obj.instance_eval(&block)
      send(:define_method, method_name) do
        variables = instance_eval(&obj.arguments_proc) || {}
        global_context = instance_eval(&context_proc || proc { {} })
        local_context = instance_eval(&obj.context_proc || proc { {} })
        context = global_context.merge(local_context)
        graphql_executor = proc do
          OntohubBackendSchema.execute(
            obj.query_string,
            variables: variables || {},
            context: context
          )
        end

        if Rest::DSL::Request.respond_with_text?(request)
          plain = proc do
            obj.plain_proc.call(graphql_executor, variables, context)
          end
          text, status = instance_eval(&plain)
          render plain: text, status: status || :ok
        else
          render json: graphql_executor.call
        end
      end
    end
  end
end
