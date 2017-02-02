# frozen_string_literal: true

# Finds and transforms constant V2::UsersController to string "v2/users".
def normalized_controller(example)
  example.example_group.controller_class.to_s.
    gsub('::', '/').sub(/Controller\z/, '').underscore
end

# finds the innermost context and transforms it from "GET show" to "get_show".
def normalized_context(example)
  example_group = example.example_group
  while (!(example_group.description =~ /\A(get|put|post|patch|delete)\s+/i))
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

RSpec::Matchers.define :comply_with_api do |schema = nil|
  errors = []
  match do |data|
    example, response = data
    controller = normalized_controller(example)
    context = normalized_context(example)
    schema_root = "#{Dir.pwd}/spec/support/api/schemas"

    errors =
      if schema
        validate_special_schema(response, schema_root, controller,
                                "#{schema}.json")
      else
        validate_controller_action(response, schema_root, controller, context)
      end
    errors += validate_special_schema(response, schema_root, controller,
                                      'jsonapi.json')

    errors.empty?
  end
  failure_message do
    header = "Found #{errors.size} JSON schema violations:"
    "#{header}\n#{errors.join("\n")}"
  end
end
