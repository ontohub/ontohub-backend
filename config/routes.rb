# frozen_string_literal: true

CONTAINING_ONE_SLASH = %r{[^/]+/[^/]+} unless defined?(CONTAINING_ONE_SLASH)
unless defined?(UNTIL_DOUBLE_SLASHES)
  UNTIL_DOUBLE_SLASHES = %r{([^/]+)(/[^/]+)*}
end

REVISION = /([^\.]+)(\.[^\.]+)*([^\.]+)/ unless defined?(REVISION)

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

  routes_with_optional_revision = lambda do
    get '/commit', controller: 'rest/commit', action: 'show'
    get '/diff/:revision', controller: 'rest/diffs', action: 'single_commit',
                           constraints: {revision: REVISION}
    get '/history/*path', controller: 'rest/history', action: 'index'
    scope '/tree' do
      get '/:path', controller: 'rest/trees', action: 'show',
                    constraints: {path: UNTIL_DOUBLE_SLASHES}
    end
    scope '/documents' do
      get '/:document_loc_id', controller: 'rest/documents', action: 'show',
                               constraints: {path: UNTIL_DOUBLE_SLASHES}
    end
  end

  # REST controller actions
  allow_double_slashes_in_routes do
    scope format: false, defaults: {format: :json} do
      # Add mappings for Devise, but skip all Devise-routes
      # We exclude these Devise mappings from these rake tasks because they
      # load the models. When loading the models, the database needs to exist,
      # or else it throws an error.
      unless rake_task?(%w(db:create db:migrate db:drop
                           db:recreate db:recreate:seed))
        devise_for :users,
          skip: %i(registrations confirmations sessions unlocks passwords)
      end

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
          get '/branches', controller: 'rest/branches', action: 'index'
          get '/branches/:name', controller: 'rest/branches', action: 'show'
          get '/tags', controller: 'rest/tags', action: 'index'
          get '/tags/:name', controller: 'rest/tags', action: 'show'
          get '/diff/:from..:to', controller: 'rest/diffs',
                                  action: 'commit_range',
                                  constraints: {from: REVISION, to: REVISION}

          routes_with_optional_revision.call
          scope '/revision/:revision' do
            routes_with_optional_revision.call
          end
        end
      end
    end
  end
end
