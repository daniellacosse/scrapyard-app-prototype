Rails.application.routes.draw do
  root to: "games#index"

  resources :games

  devise_for :players
  resources :players

  post "games/:id/join" => "games#join", as: "join_game"

  post "game_states/:id/discard_raw" => "game_states#discard_raw", as: "discard_raw"
  post "game_states/:id/ready" => "game_states#ready", as: "ready"
  post "game_states/:id/turn/end" => "game_states#end_turn", as: "end_turn"

  resources :game_states do
    resources :scrap_holds, shallow: true
    resources :blueprint_holds, shallow: true
  end
end
