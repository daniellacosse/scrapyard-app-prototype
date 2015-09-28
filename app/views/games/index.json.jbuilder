json.array!(@games) do |game|
  json.extract! game, :id, :guid
  json.url game_url(game, format: :json)
end
