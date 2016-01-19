Rails.application.routes.draw do
  resources :trades
  resources :players
  devise_for :players

  resources :games do
    resources :game_states, shallow: true do
      resources :trades, shallow: true
      resources :scrap_holds, shallow: true
      resources :blueprint_holds, shallow: true do
        resources :module_holds, shallow: true
      end
    end
  end

  root to: "games#index"
end
