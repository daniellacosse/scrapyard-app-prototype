class Target < ActiveRecord::Base
	has_many :weapon_targets
	has_many :modules, through: :weapon_targets
end
