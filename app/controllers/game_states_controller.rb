require "json"

class GameStatesController < ApplicationController
	include ActionController::Live
	before_action :authenticate_player!
	before_action :set_state, only: [
		:show, :edit, :update, :destroy, :draw, :trade, :build, :end_turn
	]

	def show
		respond_to do |format|
			format.html { render :show, locals: { scraps: Scrap.all } }

			format.json do
				response.headers["Content-Type"] = "text/event-stream"

				r = Redis.new # url: ENV["REDIS_URL"] || "redis://127.0.0.1:6379/0"
				sub_string = "stream#{@game_state.id}"

				begin
					r.subscribe sub_string do |on|
						on.message do |event, data|
							response.stream.write "event: update\n"
							response.stream.write "data: #{data}\n\n"
						end
					end
				rescue IOError
				ensure
					r.quit
					response.stream.close
				end
			end
		end
	end

	# POST /game_states/:id/draw/:card_type
   def draw
		card_id, card_type = params[:card_id], params[:card_type]

		if card_type == "scrap"
			@game_state.scrap_holds << ScrapHold.create(scrap_id: card_id)
			# TODO: check to see if any player needs that & notify them
		elsif card_type == "blueprint"
			@game_state.blueprint_holds << BlueprintHold.create(blueprint_id: card_id)
		else
	      flash[:error] = "Card type drawn (#{card_type}) invalid!";
		end

		handle_response @game_state.save
   end

	# POST /game_states/:id/sell/:scrap_hold_id
	def sell
		@scrap_hold = ScrapHold.find param[:scrap_hold_id]
		@game_state[:raw] += @scrap_hold.scrap[:value]

		transaction { success = @game_state.save && @scrap_hold.destroy }

		handle_response success
	end

   # POST /game_states/:id/trade

   # body:
   # => offer
   # => to_player_id
   # => to_Player_offer
   def trade
      # check if both parties are on their off-turn
      # check if both parties have their offer
      # make trade

		handle_response success { publish_state_data @trader_state }
   end

   # POST /game_states/:id/build/:blueprint_id
   def build
      # check if player has blueprint
      # check if player has resources
      # delete blueprint_hold and scrap_holds and create module_hold

		handle_response success
   end


	# POST /game_states/:id/turn/end
	def end_turn
		@next_player_state = @game_state.siblings.select do |player|
			player_number == @game_state.player_number + 1
		end.first

		if !@next_player_state
			@next_player_state = @game_state.siblings.select do |state|
				state.player_number == 1
			end.first
		end

		@game_state[:is_my_turn], @next_player_state[:is_my_turn] = false, true

		transaction { success = @game_state.save && @next_player_state.save }

		handle_response success { publish_state_data @next_player_state }
	end

	private
	def set_state
		@game_state = GameState.find params[:id]
	end

	def publish_state_data(data)
	  r = Redis.new # url: ENV["REDIS_URL"] || "redis://127.0.0.1:6379/0"
	  r.publish(
		  "stream#{data.id}",
		  JSON.dump(
				scraps: data.scraps.to_a.map(&:to_json),
				blueprints: data.blueprints.to_a.map(&:to_json),
				available_blueprints: data.game.available_blueprints.to_a.map(&:to_json),
				scrapper_modules: data.scrapper_modules.to_a.map(&:to_json),
				raw: data[:raw],
				is_my_turn: data[:is_my_turn]
		  )
	  )
	end

	def handle_response(no_error, &block)
		if no_error
			publish_state_data @game_state
			block

			render json: @game_state, status: :updated
		else
			render json: @game_state.errors, status: :unprocessable_entity
		end
	end
end
