class BlueprintHold < ActiveRecord::Base
	belongs_to :holdable, polymorphic: true
	belongs_to :blueprint
end
