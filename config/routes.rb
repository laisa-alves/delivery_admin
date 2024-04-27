Rails.application.routes.draw do
  devise_for :users
  resources :stores
  get "listing" => "products#listing"

  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "welcome#index"
end
