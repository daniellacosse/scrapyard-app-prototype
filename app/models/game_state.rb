class GameState < ActiveRecord::Base
	belongs_to :game
	belongs_to :player

	has_many :messages, dependent: :destroy
	has_many :trades, dependent: :destroy

	has_many :module_holds, dependent: :destroy
	has_many :scrapper_modules, through: :module_holds

	has_many :scrap_holds, dependent: :destroy
	has_many :scraps, through: :scrap_holds

	has_many :blueprint_holds, dependent: :destroy
	has_many :blueprints, through: :blueprint_holds

	def discard_resources(resource_hash)
		success = false

		transaction do
			success = update(raw: raw - resource_hash[:raw])
			resource_hash[:scrap_hold_ids]
				.each { |id| success &= ScrapHold.destroy(id) }
			resource_hash[:blueprint_hold_ids]
				.each { |id| success &= BlueprintHold.destroy(id) }
			resource_hash[:module_hold_ids]
				.each { |id| success &= ModuleHold.destroy(id) }
		end

		success
	end

	def holds?(scrap)
		scraps.include? scrap
	end

	def proposed_trades
		Trade.where()
	end

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
end
