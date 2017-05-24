# frozen_string_literal: true

# Helper methods for controller specs
module ControllerHelpers
  def response_hash
    JSON.parse(response.body)
  end

  def response_data
    response_hash['data']
  end

  def validation_error_at?(attribute)
    response_hash['errors']&.select do |error|
      error['source']['pointer'] == "/data/attributes/#{attribute}"
    end&.any?
  end

  def validation_errors_at(attribute)
    errors =
      response_hash['errors']&.select do |error|
        error['source']['pointer'] == "/data/attributes/#{attribute}"
      end
    errors&.map { |error| error['detail'] }
  end
end
