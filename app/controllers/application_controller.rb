class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected
  def authenticate_player!
    if player_signed_in?
      super
    else
      redirect_to new_player_session_path, notice: "Please Login"
    end
  end

  def publish_data(data, items)
    response = {}

    # should always say if the game has started or not
    response["started"] = data.game.has_started

    items.each do |item|
       case item
       when "players"
          response[item] = data.game.players.to_a.map do |player|
            doc = {}

            doc["id"] = player.id
            doc["email"] = player.name
            doc["isReady"] = player.game_state.is_ready
            doc["isMyTurn"] = player.game_state.is_my_turn

            doc.to_json
          end
       when "available_blueprints"
          response[item] = data.game.available_blueprints.to_a.map &:to_json
       when "raw"
          response[item] = data[:raw]
       when "scraps"
          response[item] = data.scrap_holds.to_a.map do |hold|
            doc = {}

            doc["id"] = hold.id
            doc["name"] = hold.scrap.name

            doc.to_json
          end
       when "blueprints"
          response[item] = data.blueprint_holds.to_a.map do |hold|
            doc = {}

            doc["id"] = hold.id
            doc["name"] = hold.blueprint.name

            doc.to_json
          end
       when "scrapper_modules"
          response[item] = data.scrapper_modules.to_a.map &:to_json
       end
    end

    r = Redis.new # url: ENV["REDIS_URL"] || "redis://127.0.0.1:6379/0"
    r.publish "stream#{data.id}", JSON.dump(response)
  end
end
