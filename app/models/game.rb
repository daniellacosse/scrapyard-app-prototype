class Game < ActiveRecord::Base
	has_many :game_states
	has_many :players, through: :game_states

	def available_blueprints
		taken_blueprints = game_states.collect(&:blueprints).flatten

		Blueprint.all - taken_blueprints
	end
end
