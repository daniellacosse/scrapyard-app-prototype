class ScrapHold < ActiveRecord::Base
	belongs_to :game_state
	belongs_to :scrap

	def sell
		success = false

		transaction do
			new_value = game_state.raw.to_i + scrap.value.to_i
			success = game_state.update(raw: new_value) && self.destroy
		end

		success
	end
end
