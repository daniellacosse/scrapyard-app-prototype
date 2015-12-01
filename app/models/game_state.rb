class GameState < ActiveRecord::Base
	belongs_to :game
	belongs_to :player
	has_many :cards, as: :holdable

	def siblings
		game.game_states
	end
end
