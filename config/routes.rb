Rails.application.routes.draw do
  root to: "games#index"

  resources :players
  devise_for :players

  resources :games
  resources :game_states
  resources :scrap_holds
  resources :blueprint_holds

  # mount LiveStream, at: "/live"

  # could be post games/:id/game_states
  post "games/:id/join" => "games#join", as: "join_game"

  # could be post to game_states/:id/blueprint_hold|scrap_hold
  post "game_states/:id/draw/:card_type" => "game_states#draw", as: "draw"

  # error if no reason given
  # DELETE scrap_hold, ?reason="sold"|"traded"
  post "game_states/:id/sell/:scrap_hold_id" => "game_states#sell", as: "sell"

  # error if no reason given
  # DELETE blueprint_hold, ?reason="built"|"traded"
  post "game_states/:id/build/:blueprint_id" => "game_states#build", as: "build"

  # this will be going away
  post "game_states/:id/discard_raw" => "game_states#discard_raw", as: "discard_raw"

  # not quite sure how to handle these
  post "game_states/:id/ready" => "game_states#ready", as: "ready"
  post "game_states/:id/turn/end" => "game_states#end_turn", as: "end_turn"
end
