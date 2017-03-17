# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

# :nocov:
def rake_task?(tasks = [])
  defined?(Rake) && tasks.any? do |task|
    Rake.application.top_level_tasks.include?(task)
  end
end
# :nocov:

Rails.application.routes.draw do
  scope format: false, defaults: {format: :json} do
    root to: 'v2/search#search'

    # We exclude the devise routes from these rake tasks because they load the
    # models. When loading the models, the database needs to exist, or else it
    # throws an error.
    unless rake_task?(%w(db:create db:migrate db:drop
                         db:recreate db:recreate:seed))
      devise_for :users, controllers: {sessions: 'v2/users/sessions'}
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
      constraints: {slug: %r{[^/]+/[^/]+}}

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

  # The router normalizes the paths of all routes and of all requests. This
  # also removes doubles slashes. That removal needs to be suppressed for the
  # requests because our URLs use double and even triple slashes. The following
  # flag activates a monkey patch after the routes have been loaded. It must
  # not be active during route loading because the path normalization must
  # happen then.
  # rubocop:disable Style/GlobalVars
  $do_not_merge_multiple_slashes_in_request_urls = true
end
