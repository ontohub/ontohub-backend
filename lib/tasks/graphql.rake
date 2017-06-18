# frozen_string_literal: true

namespace :graphql do
  desc 'Outputs the current schema'
  task write: :environment do
    generated = GraphQL::Schema::Printer.print_schema(OntohubBackendSchema)
    File.open(Rails.root.join('spec/support/schema.graphql'), 'w') do |f|
      f.write(generated)
    end
  end
end
