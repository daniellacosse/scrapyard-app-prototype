class Game < ActiveRecord::Base
	has_many :game_states
	has_many :players, through: :game_states
end
