Todo::Application.routes.draw do
  namespace :api do

    resources :users do
      resources :lists
    end

    resources :lists, only: [:index] do
      resources :items, only: [:create]
    end

    resources :items, only: [:destroy]

  end

  root to: 'users#new'
end
