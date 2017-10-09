# frozen_string_literal: true

desc 'Runs the development server'
task :invoker do
  exec(%(bundle exec invoker start invoker.ini))
end

namespace :invoker do
  desc 'Stops all processes that are using the database'
  task :stop_all do
    %w(ontohub-backend sneakers).each do |process|
      system('bundle', 'exec', 'invoker', 'remove', process)
    end
  end

  desc 'Starts all processes that are using the database'
  task :start_all do
    %w(ontohub-backend sneakers).each do |process|
      system('bundle', 'exec', 'invoker', 'add', process)
    end
  end
end
