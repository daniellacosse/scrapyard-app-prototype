Rails.application.routes.draw do
  devise_for :players
  resources :games
  resources :players
  resources :game_states
  root to: "games#index"

  post "games/:id/join" => "games#join", as: "join_game"

  put "game-states/:id/draw/:card_type.json" => "game_states#draw"
  put "game-states/:id/sell/:scrap_hold_id.json" => "game_states#sell"
  put "game-states/:id/trade.json" => "game_states#trade"
  put "game-states/:id/build/:blueprint_id.json" => "game_states#build"
  put "game-states/:id/turn/end.json" => "game_states#turn"
end
