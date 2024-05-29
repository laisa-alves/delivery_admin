Rails.application.routes.draw do
  devise_for :users

  resources :users, only: [:index, :destroy]

  resources :stores do
    resources :products

    collection do
      get 'discarded'
    end

    member do
      patch 'restore'
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
