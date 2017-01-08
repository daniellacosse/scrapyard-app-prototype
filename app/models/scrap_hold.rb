class ScrapHold < ActiveRecord::Base
	attr_accessor :batch_ids

	belongs_to :game_state
	belongs_to :scrap

	def sell
		success = false

		transaction do
			new_value = game_state.raw.to_i + value.to_i

			if game_state.contestant.name.start_with? "Hotei"
				new_value += 1
			end

			success = game_state.update(raw: new_value) && self.destroy
		end

		success
	end

	def player
		game_state.player
	end
end
