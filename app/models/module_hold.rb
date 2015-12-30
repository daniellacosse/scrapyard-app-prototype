class ModuleHold < ActiveRecord::Base
	belongs_to :game_state
	belongs_to :scrapper_module

	# validates_uniqueness_of :scrapper_module_id, scope: :holdable_id
end
