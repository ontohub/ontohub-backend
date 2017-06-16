class GraphqlController < ApplicationController
  def execute_single(query, context)
    variables = ensure_hash(query[:variables])
    query = query[:query]
    OntohubBackendSchema.execute(query, variables: variables, context: context)
  end

  def execute
    context = {
      current_user: current_user
    }
    if params[:_json]
      # Batched request
      queries = params[:_json]
      result = queries.map do |query|
        execute_single(query, context)
      end
    else
      result = execute_single({query: params[:query],
			       variables: params[:variables]}, context)
    end

    render json: result
  end

  private

  # Handle form data, JSON body, or a blank value
  def ensure_hash(ambiguous_param)
    case ambiguous_param
    when String
      if ambiguous_param.present?
        ensure_hash(JSON.parse(ambiguous_param))
      else
        {}
      end
    when Hash, ActionController::Parameters
      ambiguous_param
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
    end
  end
end
