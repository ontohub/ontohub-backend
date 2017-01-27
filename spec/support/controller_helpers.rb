# frozen_string_literal: true

# Helper methods for controller specs
module ControllerHelpers
  def response_hash
    JSON.parse(response.body)
  end

  def response_data
    response_hash['data']
  end
end
