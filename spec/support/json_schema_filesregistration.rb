# frozen_string_literal: true

# Register all JSON schemata before running the test suite.  This way, they can
# be referenced with a
# "$ref": "<id of the other schema>"
# property in the schema. This id can be the relative file path to the
# version-namespaced schemas directory.
SCHEMA_ROOT = Rails.root.join('spec/support/api/schemas')
Dir[SCHEMA_ROOT.join('**/*.json')].each do |absolute_schema_file|
  schema = JSON::Schema.new(JSON.parse(File.read(absolute_schema_file)),
                            Addressable::URI.parse(absolute_schema_file.to_s))
  JSON::Validator.add_schema(schema)
end
