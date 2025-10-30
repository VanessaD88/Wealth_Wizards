Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  # Gameboard route
  # get "/gameboard", to: "challenges#index", as: :gameboard
  #
  resources :gameboards, only: [:show, :create] do
    resources :challenges, only: [:show, :index]
  end

  get "/gameboard", to: "pages#gameboard", as: :pages_gameboard

  # Levels overview page (index is conditional view); POST for starting/reseting journey
  resources :levels, only: [:index, :create]


  # Challenges routes
  resources :challenges, only: [:index, :show, :create]

    # Gameboard routes
  resource :gameboard, only: [:show], controller: "gameboards"
  post "/gameboard/challenges", to: "gameboards#draw", as: :draw_gameboard_challenge

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
