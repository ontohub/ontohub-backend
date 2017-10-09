# frozen_string_literal: true

require 'factory_girl_rails'
require 'faker'
require 'ontohub-models/factories'

# Do not enqueue jobs but perform them straight away
ActiveJob::Base.queue_adapter = :inline

Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each { |seed| load seed }
