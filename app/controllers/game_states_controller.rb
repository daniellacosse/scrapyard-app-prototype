class GameStatesController < ActionController::Base
	include ActionController::Live

	def show
		@game_state = GameState.find params["id"]
		@game = @game_state.game
		@players = @game.players

		response.headers['Content-Type'] = 'text/event-stream'
		sse = GameStateHelper::SSE.new(response.stream)

		begin
			loop do
				sse.write @players.collect &:email

				sleep 2
			end
		rescue IOError
		ensure
			sse.close
		end
	end
end
