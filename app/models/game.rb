class Game < ActiveRecord::Base
	has_many :game_states
	has_many :players, through: :game_states

	def available_blueprints
		taken_blueprints = game_states.collect(&:blueprints).flatten
		built_blueprints = game_states.collect(&:scrapper_modules).flatten.map(&:blueprint)

		Blueprint.all - taken_blueprints - built_blueprints
	end

	def start_if_all_ready
		if game_states.collect(&:is_ready).all?
			success = update(has_started: true)

			success &= game_states.shuffle.each_with_index do |state, i|
				success &= state.update(player_number: i)
			end.first.update(is_my_turn: true)

			return success
		end
	end
end
