class BlueprintHold < ActiveRecord::Base
	belongs_to :holdable, polymorphic: true
	belongs_to :blueprint

	validates_uniqueness_of :blueprint_id, scope: :holdable_id
end
