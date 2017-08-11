# frozen_string_literal: true

namespace :sneakers do
  desc 'Run all sneakers workers'
  task run_all: :environment do
    require Rails.root.join('lib/sneakers/worker')

    queues = [:mailers].map { |q| Sneakers::Workers.create(q).to_s }.join(',')

    ENV['WORKERS'] = queues

    Rake::Task['sneakers:run'].invoke
  end
end
