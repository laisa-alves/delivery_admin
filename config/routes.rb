Rails.application.routes.draw do
  devise_for :users
  resources :stores
  get "listing" => "products#listing"

  post "new" => "registrations#create", as: :create_registration
  post "sign_in" => "registrations#sign_in"
  get "me" => "registrations#me"

  root "welcome#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
