class GameState < ActiveRecord::Base
	belongs_to :game
	belongs_to :player
	belongs_to :contestant

	has_many :messages, dependent: :destroy

	has_many :module_holds, dependent: :destroy
	has_many :scrapper_modules, through: :module_holds

	has_many :scrap_holds, dependent: :destroy
	has_many :scraps, through: :scrap_holds

	has_many :blueprint_holds, dependent: :destroy
	has_many :blueprints, through: :blueprint_holds

	def discard_resources(resource_hash)
		success = false

		transaction do
			success = update(raw: raw - resource_hash["raw"])

			# TODO: temporary thing — I think?
			if resource_hash["scraps"]
				resource_hash["scraps"].each do |scrap|
					success &= scrap_holds
						.select { |hold| hold.scrap.id == scrap["id"] }
						.sort_by { |hold| hold.value }
						.first.destroy()
				end
			end

			if resource_hash["scrap_hold_ids"]
				resource_hash["scrap_hold_ids"]
					.each { |id| success &= ScrapHold.destroy(id) }
			end

			if resource_hash["blueprint_hold_ids"]
				resource_hash["blueprint_hold_ids"]
					.each { |id| success &= BlueprintHold.destroy(id) }
			end

			if resource_hash["module_hold_ids"]
				resource_hash["module_hold_ids"]
					.each { |id| success &= ModuleHold.destroy(id) }
			end
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

	def actionable_trades
		game.trades.select do |trade|
		  result = true

		  if trade.is_agreed
			  result = false
		  else
				result = (
					trade.solicited_player.id == player.id
				) || (
					trade.is_revised && trade.solicitor_player.id == id
				)
			end

			result
		end
	end

	def add_scrap_hold(id)
		scrap_id, scrap_value = *id.split("-")
		if !!Scrap.find(scrap_id)
			hold = ScrapHold.create(scrap_id: scrap_id.to_i, value: scrap_value.to_i)

			if hold.persisted?
				scrap = hold.scrap
				scrap_holds << hold

				siblings.includes(:blueprints).each do |sibling|
					matches = []
					alert_text = ""

					if sibling.id == id
						matches = sibling.blueprints.to_a.select { |bp| bp.requires?(scrap) }

						alert_text = <<-HEREDOC
Note!: The #{scrap.name} you just drew could be used to help brew any of the following:
#{matches.map(&:name).join(', ')}
						HEREDOC
					else
						matches = sibling.blueprints.to_a.select do |bp|
							!sibling.holds?(scrap) && bp.requires?(scrap)
						end

						alert_text = <<-HEREDOC
#{player.email} drew a(n) #{scrap.name}!
(You need one for: #{matches.map(&:name).join(', ')}.)
HEREDOC
					end

					if matches.length > 0
						Message.create(game_state_id: sibling.id, text: alert_text)
					end
				end
			end
		else
			return "Unable to create scrap hold."
		end
	end

	def add_blueprint_hold(module_class, class_id)
		found_module = ScrapperModule.find_by(module_class: module_class, class_id: class_id.to_i)

		if !!found_module
			hold = BlueprintHold.create(
				blueprint_id: found_module.blueprint_id, game_id: game.id
			)

			if hold.persisted?
				blueprint_holds << hold
			else
				return "Unable to create blueprint hold."
			end
		end
	end
end
