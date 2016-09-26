# frozen_string_literal: true

# Register all JSON schemata before running the test suite.  This way, they can
# be referenced with a
# "$ref": "<id of the other schema>"
# property in the schema. This id can be the relative file path to the
# version-namespaced schemas directory.
Dir['spec/support/api/*/schemas/*.json'].each do |schema_file|
  absolute_schema_file = Rails.root.join(schema_file).to_s
  schema = JSON::Schema.new(JSON.parse(File.read(absolute_schema_file)),
                            Addressable::URI.parse(absolute_schema_file))
  JSON::Validator.add_schema(schema)
end
