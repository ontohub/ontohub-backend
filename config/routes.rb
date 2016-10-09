# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :namespaces,
    format: false,
    controller: 'v2/namespaces',
    only: :show,
    param: :slug do
      resources :repositories,
        format: false,
        controller: 'v2/repositories',
        except: %i(new edit),
        param: :slug
    end
end
