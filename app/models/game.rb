class Game < ActiveRecord::Base
	has_many :game_states
	has_many :players, through: :game_states

	def available_blueprints
		taken_blueprints = game_states.collect(&:blueprints).flatten

		Blueprint.all - taken_blueprints
	end

	def start_if_all_ready
		success = update(has_started: true) if game_states.collect(&:is_ready).all?

		return success
	end
end
