# frozen_string_literal: true

namespace :db do
  task recreate: 'repo:clean' do
    Rake::Task['db:recreate'].invoke
  end

  namespace :recreate do
    desc 'Recreate the database (drop, create, migrate) and seed'
    task seed: 'db:recreate' do
      Rake::Task['db:seed'].invoke
    end
  end
end
