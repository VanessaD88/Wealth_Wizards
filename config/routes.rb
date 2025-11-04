Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  root to: "pages#home"

  # Gameboard route
  # get "/gameboard", to: "challenges#index", as: :gameboard
  #
  resources :gameboards, only: [:show, :create] do
    resources :challenges, only: [:show, :index]
  end

  get "/gameboard", to: "pages#gameboard", as: :pages_gameboard

  # Levels overview page (index is conditional view); POST for starting/reseting journey
  # Minimal nested route for creating a challenge under a level (required for level_challenges_path(@level))
  resources :levels, only: [:index, :create] do
    resources :challenges, only: [:create]
  end


  # Challenges routes
  # Decision rationale:
  
  # - :index (GET /challenges) - NOT INCLUDED: Challenges are displayed via pages#gameboard, not a standalone challenges index.
  #   The challenges#index method exists but is unused; list view is handled by the gameboard page.
  # - :new (GET /challenges/new) - NOT INCLUDED: Challenge creation is automated via AI in create action, no manual form needed.
  #   The create action renders :new on error but this is defensive coding, not core functionality.
  resources :challenges, only: [:show, :create] do
    # Member route for updating user's choice on an existing challenge (used by gameboard form submission)
    member do
      patch :select_choice
    end
  end

    # Gameboard routes
  resource :gameboard, only: [:show], controller: "gameboards"
  post "/gameboard/challenges", to: "gameboards#draw", as: :draw_gameboard_challenge

  # User routes
  resources :users, only: :show, controller: "profiles"
  resource :profile, only: [:show, :edit, :update]

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # dashboard route
  get "dashboard", to: "pages#dashboard", as: :dashboard

  # Test route for gold rain effects (remove in production)
  get "test/gold-rain", to: "pages#gold_rain_test", as: :gold_rain_test
end
