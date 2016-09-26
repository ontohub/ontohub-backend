# frozen_string_literal: true

RSpec::Matchers.
  define :match_response_schema do |api_version, schema, strict = true|
  errors = []
  match do |response|
    schema_directory = "#{Dir.pwd}/spec/support/api/#{api_version}/schemas/"
    schema_path = "#{schema_directory}/#{schema}.json"
    errors = JSON::Validator.fully_validate(schema_path, response.body,
                                   strict: strict, validateschema: true)
    errors.empty?
  end
  failure_message do
    header = "Found #{errors.size} JSON schema violations:"
    "#{header}\n#{errors.join("\n")}"
  end
end
