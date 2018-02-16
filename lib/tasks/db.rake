# frozen_string_literal: true

namespace :db do
  task recreate: ['invoker:stop_all', 'repo:clean'] do
    Rake::Task['db:recreate'].invoke
    Rake::Task['invoker:start_all'].invoke
  end

  desc "Truncate all tables"
  task truncate: [:environment, 'repo:clean'] do
    db = Sequel::Model.db
    tables = db.tables - %i(schema_migrations)
    all_tables = tables.map do |table|
      %("#{table}")
    end.join(',')

    db.run "TRUNCATE TABLE #{all_tables}"
  end

  namespace :recreate do
    desc 'Recreate the database (drop, create, migrate) and seed'
    task seed: 'db:recreate' do
      Rake::Task['db:seed'].invoke
    end

    desc "Recreate all tables"
    task tables: [:environment, 'repo:clean'] do
      db = Sequel::Model.db
      all_tables = db.tables.map do |table|
        %("#{table}")
      end.join(',')

      db.run "DROP TABLE #{all_tables}"
      Rake::Task['db:migrate'].invoke
    end

    namespace :tables do
      desc 'Recreate all tables and seed'
      task seed: 'db:recreate:tables' do
        Rake::Task['db:seed'].invoke
      end
    end
  end

  namespace :truncate do
    desc 'Truncate all tables and seed'
    task seed: 'db:truncate' do
      Rake::Task['db:seed'].invoke
    end
  end
end
