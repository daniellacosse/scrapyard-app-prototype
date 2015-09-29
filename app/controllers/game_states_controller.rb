class GameStatesController < ActionController::Base
	include ActionController::Live

	def show
		@state = GameState.find params["id"]
		response.headers['Content-Type'] = 'text/event-stream'

		r = Redis.new()
		begin
			r.subscribe("state.game#{@state.game.id}") do |on|
				on.message do |event, data|
					puts event
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
