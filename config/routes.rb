Rails.application.routes.draw do
  devise_for :players
  resources :games
  resources :players
  resources :game_states
  resources :scrap_holds
  resources :blueprint_holds
  root to: "games#index"

  post "games/:id/join" => "games#join", as: "join_game"

  post "game_states/:id/draw/:card_type" => "game_states#draw", as: "draw"
  post "game_states/:id/sell/:scrap_hold_id" => "game_states#sell", as: "sell"
  post "game_states/:id/build/:blueprint_id" => "game_states#build", as: "build"
  post "game_states/:id/ready" => "game_states#ready", as: "ready"
  post "game_states/:id/turn/end" => "game_states#end_turn", as: "end_turn"

  #TODO: destroy scrap_hold, blueprint_hold
end
