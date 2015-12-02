class GameState < ActiveRecord::Base
	belongs_to :game
	belongs_to :player

	has_many :module_holds
	has_many :scrapper_modules, through: :module_holds

	has_many :scrap_holds
	has_many :scraps, through: :scrap_holds

	has_many :blueprint_holds
	has_many :blueprints, through: :blueprint_holds

	def siblings
		game.game_states
	end
end
