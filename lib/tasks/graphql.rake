require 'open3'

namespace :graphql do
  desc "Compares the current graphql schema with the saved one"
  task compare: :environment do
    generated = GraphQL::Schema::Printer.print_schema(OntohubBackendSchema)
    output, status = Open3.capture2("diff -u #{Rails.root.join('config/schema.graphql')} -", stdin_data: generated)
    if output.empty?
      STDERR.puts "Schema matches!"
    else 
      STDERR.puts output
      STDERR.puts "Schema differs. Please regenerate the schema file by running `rake graphql:write`"
      exit 1
    end
  end

  desc "Outputs the current schema"
  task write: :environment do
    generated = GraphQL::Schema::Printer.print_schema(OntohubBackendSchema)
    File.open(Rails.root.join('config/schema.graphql'), 'w') do |f|
      f.write(generated)
    end
  end
end
