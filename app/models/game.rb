class Game < ActiveRecord::Base
	has_many :game_states
	has_many :players, through: :game_states

	def available_blueprints
		game_states
			.collect(&:cards)
			.flatten
			.select { |card| card[:holdable_type] == "blueprint" }
			.collect(&:id)
	end
end
