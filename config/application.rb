# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
# require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
# require 'sprockets/railtie'
# require 'rails/test_unit/railtie'
require 'devise'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OntohubBackend
  # The base application class - Rails default
  class Application < Rails::Application
    config.hets_version_requirement = '>= 0.100.0'
    config.document_file_extensions =
      %w(casl dol hascasl het owl omn obo hs exp maude elf hol isa thy prf
         omdoc hpf clf clif xml fcstd rdf xmi qvt p tptp gen_trm baf).
        map { |ext| ".#{ext}" }
    config.lockdir = File.join(Dir.tmpdir, 'ontohub-backend', 'lock')

    # Settings in config/environments/* take precedence over those specified
    # here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.before_initialize do
      local_environment_config = config.root.join('config', 'environments',
                                                  "#{Rails.env}.local.rb")
      require local_environment_config if File.exist?(local_environment_config)
    end

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # The host for URL generators
    routes.default_url_options = {host: 'localhost:3000'}

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: :any
      end
    end

    config.autoload_paths << Rails.root.join('lib')

    # Sequel 5 and sequel-rails always try connect to the database, even if it
    # does not exist AND it should be created by the currently running rake
    # task. This is a workaround:
    tasks_without_connection =
      %w(db:drop db:create db:recreate db:recreate:seed)
    # :nocov:
    config.sequel.skip_connect =
      defined?(Rake) &&
      (Rake.application.top_level_tasks & tasks_without_connection).any?
    # :nocov:

    config.after_initialize do
      SettingsHandler.new(Settings).call

      # Only interact with the HetsAgent if the application is not run via rake
      # but as the rails server
      unless defined?(Rake)
        HetsAgentIninializer.new.call
        HetsAgent::Invoker.new(HetsAgent::LogicGraphRequestCollection.new).call
      end
    end
  end
end
