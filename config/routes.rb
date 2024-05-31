Rails.application.routes.draw do
  devise_for :users

  resources :users, only: [:index, :destroy] do
    collection do
      get 'admin_new', to: 'users#admin_new'
      post 'admin_create', to: 'users#admin_create'
      get 'discarded'
    end

    member do
      patch 'restore'
    end
  end

  resources :stores do
    resources :products do
      collection do
        get 'public', to: 'products#public_index'
      end

      member do
        patch 'toggle_active'
      end
    end

    collection do
      get 'discarded'
    end

    member do
      patch 'restore'
      patch 'toggle_active'
    end

  end

  get "listing" => "products#listing"

  post "new" => "registrations#create", as: :create_registration
  post "sign_in" => "registrations#sign_in"
  get "me" => "registrations#me"

  scope :buyers do
    resources :orders, only: [:index, :create, :update, :destroy]
  end

  root "welcome#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
