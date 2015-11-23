class Target < ActiveRecord::Base
	has_many :weapon_targets
	has_many :scrapper_modules, through: :weapon_targets
end
