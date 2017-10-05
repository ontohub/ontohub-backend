# frozen_string_literal: true

namespace :db do
  task recreate: ['invoker:stop_all', 'repo:clean'] do
    Rake::Task['db:recreate'].invoke
    Rake::Task['invoker:start_all'].invoke
  end

  namespace :recreate do
    desc 'Recreate the database (drop, create, migrate) and seed'
    task seed: 'db:recreate' do
      Rake::Task['db:seed'].invoke
    end
  end
end
