# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

CONTAINING_ONE_SLASH = %r{[^/]+/[^/]+} unless defined?(CONTAINING_ONE_SLASH)
unless defined?(UNTIL_DOUBLE_SLASHES)
  UNTIL_DOUBLE_SLASHES = %r{([^/]+)(/[^/]+)*}
end

# :nocov:
def rake_task?(tasks = [])
  defined?(Rake) && tasks.any? do |task|
    Rake.application.top_level_tasks.include?(task)
  end
end
# :nocov:

# The router normalizes the paths of all routes and of all requests. This
# also removes doubles slashes. That removal needs to be suppressed for the
# requests because our URLs use double and even triple slashes. The following
# flag activates a monkey patch after the routes have been loaded. It must
# not be active during route loading because the path normalization must
# happen then. With this method, we enable normalization for route definitions
# inside the provided block and disable normalization outside.
def allow_double_slashes_in_routes
  # rubocop:disable Style/GlobalVars
  $do_not_merge_multiple_slashes_in_request_urls = false
  yield
  $do_not_merge_multiple_slashes_in_request_urls = true
  # rubocop:enable Style/GlobalVars
end

Rails.application.routes.draw do
  if Rails.env.development?
    # :nocov:
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
    # :nocov:
  end

  post '/graphql', to: 'graphql#execute'

  # REST controller actions
  allow_double_slashes_in_routes do
    scope format: false, defaults: {format: :json} do
      # Add mappings for Devise, but skip all Devise-routes
      devise_for :users,
        skip: %i(registrations confirmations sessions unlocks passwords)

      # Add routes to a no-op action to create URL-helpers that are used in
      # confirmation, password-reset and unlock emails
      scope 'account' do
        get 'confirm-email',
          controller: 'rest/application', action: 'no_op', as: :confirmation
        get 'edit-password',
          controller: 'rest/application', action: 'no_op', as: :edit_password
        get 'unlock',
          controller: 'rest/application', action: 'no_op', as: :unlock
      end

      root to: 'rest/version#show'

      get 'version', controller: 'rest/version', action: 'show'

      get ':slug', controller: 'rest/organizational_units', action: 'show'

      scope ':organizational_unit_id' do
        get 'repositories', controller: 'rest/repositories', action: 'index'

        scope ':repository_id' do
          get '/', controller: 'rest/repositories', action: 'show'
        end
      end
    end
  end
end
