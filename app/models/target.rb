class Target < ActiveRecord::Base
	has_many :part_targets
	has_many :parts, through: :part_targets
end
