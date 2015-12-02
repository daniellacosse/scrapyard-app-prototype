Rails.application.routes.draw do
  devise_for :players
  resources :games
  resources :players
  resources :game_states
  root to: "games#index"

  post "games/:id/join" => "games#join", as: "join_game"

  post "game_states/:id/draw/:card_type" => "game_states#draw", as: "draw"
  post "game_states/:id/sell/:scrap_hold_id" => "game_states#sell", as: "sell"
  post "game_states/:id/trade" => "game_states#trade", as: "trade"
  post "game_states/:id/build/:blueprint_id" => "game_states#build", as: "build"
  post "game_states/:id/turn/end" => "game_states#turn_end", as: "turn_end"
end
