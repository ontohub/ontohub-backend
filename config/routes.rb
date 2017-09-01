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
      get 'version', controller: 'rest/version', action: 'show'
      get ':slug',
        controller: 'rest/organizational_units', action: 'show'
      get ':organizational_unit_id/repositories',
        controller: 'rest/repositories', action: 'index'
      get ':organizational_unit_id/:repository_id',
        controller: 'rest/repositories', action: 'show'
    end
  end
end
