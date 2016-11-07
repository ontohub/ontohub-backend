# frozen_string_literal: true

Rails.application.routes.draw do
  resources :namespaces,
    format: false,
    controller: 'v2/namespaces',
    only: :show,
    param: :slug do
      resources :repositories,
        format: false,
        controller: 'v2/repositories',
        only: :index
    end

  # Repositories is actually nested in namespaces, but its slug contains the
  # namespace's slug, separated by a slash.
  resources :repositories,
    format: false,
    controller: 'v2/repositories',
    except: %i(index new edit),
    param: :slug,
    constraints: {slug: %r{[^/]+/[^/]+}}
end
