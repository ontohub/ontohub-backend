# frozen_string_literal: true

def normalized_rest_controller(example)
  example.example_group.controller_class.to_s.
    gsub('::', '/').underscore
end

# finds the innermost context and transforms it from "GET show" to "get_show".
def normalized_rest_controller_action(example)
  example_group = example.example_group
  until example_group.description =~ /\Aaction:\s+/i
    example_group = example_group.parent
  end
  example_group&.description&.sub(/action:\s+/, '')&.parameterize&.underscore
end

def validate_rest_controller_action(response, schema_root, controller, action)
  schema_path = "#{schema_root}/#{controller}.json"
  fragment = "#/definitions/actions/#{action}"
  JSON::Validator.fully_validate(schema_path, response.body,
                                 strict: false,
                                 fragment: fragment)
end

RSpec::Matchers.define :comply_with_rest_api do
  errors = []
  match do |data|
    example, response = data
    controller = normalized_rest_controller(example)
    action = normalized_rest_controller_action(example)
    schema_root = "#{Rails.root}/spec/support/api/schemas"

    errors =
      validate_rest_controller_action(response, schema_root, controller, action)

    errors.empty?
  end
  failure_message do
    header = "Found #{errors.size} JSON schema violations:"
    "#{header}\n#{errors.join("\n")}"
  end
end
