# frozen_string_literal: true

module V3
  module DSL
    class GraphqlDSLObject
      attr_reader :query_string, :arguments_proc, :context_proc

      def initialize()
        @arguments_proc = Proc.new {}
        @context_proc = Proc.new {}
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

    def graphql(method_name, &block)
      obj = GraphqlDSLObject.new
      obj.instance_eval(&block)
      self.send(:define_method, method_name) do
        variables = self.instance_eval(&obj.arguments_proc)
        context = self.instance_eval(&obj.context_proc)

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
