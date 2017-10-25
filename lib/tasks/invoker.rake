# frozen_string_literal: true

desc 'Runs the development server'
task :invoker do
  exec(%(bundle exec invoker start invoker.ini))
end

namespace :invoker do
  desc 'Stops all processes that are using the database'
  task :stop_all do
    %w(ontohub-backend sneakers hets-agent).each do |process|
      system("bundle exec invoker remove #{process} 1> /dev/null 2> /dev/null")
    end
  end

  desc 'Starts all processes that are using the database'
  task :start_all do
    %w(ontohub-backend sneakers hets-agent).each do |process|
      system("bundle exec invoker add #{process} 1> /dev/null 2> /dev/null")
    end
  end
end
