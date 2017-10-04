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

    config.after_initialize do
      SettingsHandler.new(Settings).call
    end
  end
end
