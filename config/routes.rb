# frozen_string_literal: true

Rails.application.routes.draw do
  scope format: false do
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
  end
end
