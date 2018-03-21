# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'
require 'ontohub-models/factories'

Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each { |seed| load seed }
