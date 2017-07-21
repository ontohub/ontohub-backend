# frozen_string_literal: true

# Finds and transforms constant V2::UsersController to string "v2/users".
def normalized_controller(example)
  example.example_group.controller_class.to_s.
    gsub('::', '/').sub(/Controller\z/, '').underscore
end

# finds the innermost context and transforms it from "GET show" to "get_show".
def normalized_context(example)
  example_group = example.example_group
  until example_group.description =~ /\A(get|put|post|patch|delete)\s+/i
    example_group = example_group.parent
  end
  example_group&.description&.parameterize&.underscore
end

def validate_controller_action(response, schema_root, controller, context)
  schema_path = "#{schema_root}/controllers/#{controller}/#{context}.json"
  JSON::Validator.fully_validate(schema_path, response.body,
                                 strict: false,
                                 validateschema: true)
end

def validate_special_schema(response, schema_root, controller, schema)
  version = controller.sub(%r{/.*}, '')
  schema_path = File.join(schema_root, 'controllers', version, schema)
  JSON::Validator.fully_validate(schema_path, response.body,
                                 strict: false,
                                 validateschema: true)
end

RSpec::Matchers.define :comply_with_api do |schema = nil, verify_jsonapi = true|
  errors = []
  match do |data|
    example, response = data
    controller = normalized_controller(example)
    context = normalized_context(example)
    schema_root = "#{Rails.root}/spec/support/api/schemas"

    errors =
      if schema
        validate_special_schema(response, schema_root, controller,
                                "#{schema}.json")
      else
        validate_controller_action(response, schema_root, controller, context)
      end

    if verify_jsonapi
      errors += validate_special_schema(response, schema_root, controller,
                                        'jsonapi.json')
    end

    errors.empty?
  end
  failure_message do
    header = "Found #{errors.size} JSON schema violations:"
    "#{header}\n#{errors.join("\n")}"
  end
end

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
  schema_path = "#{schema_root}/controllers/#{controller}.json"
  JSON::Validator.fully_validate(schema_path, response.body,
                                 strict: false,
                                 validateschema: true)
  # TODO: uncomment this as soon as fragments work
                                 # fragment: "#/definitions/actions/#{action}")
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
