# frozen_string_literal: true

namespace :graphql do
  desc 'Outputs the current schema'
  task write: :environment do
    generated = GraphQL::Schema::Printer.print_schema(OntohubBackendSchema)
    File.write(Rails.root.join('spec/support/schema.graphql'), "#{generated}\n")
  end

  desc 'Write the GraphQL schema json file to FILE=graphql_schema.json'
  task write_json: :environment do
    output_file = ENV['FILE'] || 'graphql_schema.json'
    schema_hash = OntohubBackendSchema.
      execute(GraphQL::Introspection::INTROSPECTION_QUERY)
    File.write(output_file, schema_hash.to_json)
  end
end
