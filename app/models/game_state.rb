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

	def set_ready
		success = false

		transaction do
			success = update(is_ready: true)
			success &= game.start_if_all_ready
		end

		success
	end

	def holds?(scrap)
		scraps.include? scrap
	end
end
