# frozen_string_literal: true

namespace :db do
  namespace :recreate do
    desc 'Recreate the database (drop, create, migrate) and seed'
    task seed: 'db:recreate' do
      Rake::Task['db:seed'].invoke
    end
  end
end
