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

Rails.application.routes.draw do
  if Rails.env.development?
    # :nocov:
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
    # :nocov:
  end

  post '/graphql', to: 'graphql#execute'
  # The router normalizes the paths of all routes and of all requests. This
  # also removes doubles slashes. That removal needs to be suppressed for the
  # requests because our URLs use double and even triple slashes. The following
  # flag activates a monkey patch after the routes have been loaded. It must
  # not be active during route loading because the path normalization must
  # happen then. Here, we enable normalization. At the end of this block, we
  # disable it again.
  # rubocop:disable Style/GlobalVars
  $do_not_merge_multiple_slashes_in_request_urls = false
  # rubocop:enable Style/GlobalVars

  # We need these routes multiple times:
  routes_under_repository = lambda do
    scope '/tree' do
      patch '/', controller: 'v2/trees', action: 'multiaction'
      post '/', controller: 'v2/trees', action: 'create'
      get '/', controller: 'v2/trees', action: 'show', defaults: {path: ''}
      patch '/:path',
        controller: 'v2/trees',
        action: 'update',
        constraints: {path: UNTIL_DOUBLE_SLASHES}
      delete '/:path',
        controller: 'v2/trees',
        action: 'destroy',
        constraints: {path: UNTIL_DOUBLE_SLASHES}
      get '/:path',
        controller: 'v2/trees',
        action: 'show',
        constraints: {path: UNTIL_DOUBLE_SLASHES}
    end
  end

  scope '/v3', format: false, defaults: {format: :json} do
    get 'version', controller: 'v3/version', action: 'show'
    get '/:slug',
      controller: 'v3/organizational_units',
      action: 'show'
  end

  scope format: false, defaults: {format: :json} do
    root to: 'v2/search#search'

    # We exclude the devise routes from these rake tasks because they load the
    # models. When loading the models, the database needs to exist, or else it
    # throws an error.
    unless rake_task?(%w(db:create db:migrate db:drop
                         db:recreate db:recreate:seed))
      devise_for :users,
        controllers: {registrations: 'v2/users/account',
                      confirmations: 'v2/users/confirmation',
                      sessions: 'v2/users/sessions',
                      unlocks: 'v2/users/unlocks',
                      passwords: 'v2/users/passwords'},
        skip: [:registrations, :confirmations, :sessions, :unlocks, :passwords]
      scope 'users' do
        devise_scope :user do
          post '', controller: 'v2/users/account', action: 'create'
          patch '', controller: 'v2/users/account', action: 'update'
          delete '', controller: 'v2/users/account', action: 'destroy'

          post '/confirmation',
            controller: 'v2/users/confirmation',
            action: 'resend_confirmation_email',
            as: nil
          patch '/confirmation',
            controller: 'v2/users/confirmation',
            action: 'confirm_email_address',
            as: :user_confirmation

          # The edit action is a no-op in the backend. It needs to be available,
          # though, because Devise needs the url helpers.
          get '/password',
            controller: 'v2/users/passwords', action: 'edit',
            as: :edit_user_password
          post '/password',
            controller: 'v2/users/passwords',
            action: 'resend_password_recovery_email'
          patch '/password',
            controller: 'v2/users/passwords',
            action: 'recover_password'

          post 'sign_in', controller: 'v2/users/sessions', action: 'create'
          delete 'sign_out', controller: 'v2/users/sessions', action: 'destroy'

          post '/unlock',
            controller: 'v2/users/unlock', action: 'resend_unlocking_email',
            as: nil
          patch '/unlock',
            controller: 'v2/users/unlock', action: 'unlock_account',
            as: :user_unlock
        end
        get '/me', controller: 'v2/users', action: 'show_current_user'
      end
    end
    resources :organizations,
      controller: 'v2/organizations',
      only: :show,
      param: :slug do
        resources :repositories,
          controller: 'v2/repositories',
          only: :index
      end

    resources :users,
      controller: 'v2/users',
      only: :show,
      param: :slug do
        resources :repositories,
          controller: 'v2/repositories',
          only: :index
      end

    # Repositories are actually nested in users/organizations, but its slug
    # contains the owner's slug, separated by a slash.
    resources :repositories,
      controller: 'v2/repositories',
      except: %i(index new edit),
      param: :slug,
      constraints: {slug: CONTAINING_ONE_SLASH}

    get 'search', controller: 'v2/search', action: 'search'
    get 'version', controller: 'v2/version', action: 'show'

    scope '/organizational_units' do
      get '/:slug',
        controller: 'v2/organizational_units',
        action: :show
    end

    # Repositories
    resources '/',
      param: :slug,
      controller: 'v2/repositories',
      except: %i(index new create edit),
      constraints: {slug: CONTAINING_ONE_SLASH}

    # Below Repositories
    scope '/:repository_slug',
      constraints: {repository_slug: CONTAINING_ONE_SLASH} do
        routes_under_repository.call
        # by reference
        scope '/ref/:ref' do
          routes_under_repository.call
        end
      end

    # Easy access to Organizational Units
    get '/:slug',
      controller: 'v2/organizational_units',
      action: :show,
      as: :organizational_unit
  end

  # The router normalizes the paths of all routes and of all requests. Disable
  # normalizing it. See the comment at the beginning of the current block.
  # rubocop:disable Style/GlobalVars
  $do_not_merge_multiple_slashes_in_request_urls = true
  # rubocop:enable Style/GlobalVars
end
