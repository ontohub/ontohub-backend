# frozen_string_literal: true

# Controller for the GraphQL API endpoint
class GraphqlController < ApplicationController
  def execute
    if params[:query]
      variables = ensure_hash(params[:variables])
      result = OntohubBackendSchema.execute(
        query: params[:query],
        variables: variables,
        context: context
      )
    else
      result = OntohubBackendSchema.multiplex(
        queries
      )
    end
    render json: result
  end

  private

  def context
    {
      current_user: current_user,
      request: request,
    }
  end

  def queries
    params.permit(_json: [:query, :operationName, {variables: {}}]).
      to_hash['_json'].map do |query|
        query.transform_keys do |k|
          k.underscore.to_sym
        end.merge(context: context)
      end
  end

  # Handle form data, JSON body, or a blank value
  # :nocov:
  # rubocop:disable Metrics/MethodLength
  def ensure_hash(ambiguous_param)
    # rubocop:enable Metrics/MethodLength
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
  # :nocov:
end
