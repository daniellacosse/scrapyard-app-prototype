class RequirementOption < ActiveRecord::Base
	belongs_to :requirement
	belongs_to :option
end
