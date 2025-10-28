Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  # Gameboard route
  get "/gameboard", to: "gameboard#show", as: :gameboard

  # Challenges routes
  resources :challenges, only: [:index, :show, :create]

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
