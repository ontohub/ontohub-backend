# frozen_string_literal: true

namespace :sneakers do
  desc 'Run all sneakers workers'
  task run: :environment do
    config = Settings.sneakers
    runner = Sneakers::MultiRunner.new(config)
    runner.run
  end
end
