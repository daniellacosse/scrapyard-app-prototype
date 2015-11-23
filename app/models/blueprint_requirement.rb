class BlueprintRequirement < ActiveRecord::Base
	belongs_to :blueprint
	belongs_to :requirement
end
