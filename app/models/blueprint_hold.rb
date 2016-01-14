class BlueprintHold < ActiveRecord::Base
	attr_accessor :batch_ids

	belongs_to :game_state
	belongs_to :blueprint

	validates_uniqueness_of :blueprint_id, scope: :game_id
end
