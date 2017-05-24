# frozen_string_literal: true

# This formats devise errors according to json api.
class JsonApiFailureApp < Devise::FailureApp
  def respond
    if request.format == :json
      json_error_response
    else
      super
    end
  end

  def json_error_response
    self.status = 401
    self.content_type = 'application/json'
    error = JSON.parse(http_auth_body)['error']
    self.response_body = {'errors' => [{'detail' => error}]}.to_json
  end
end
