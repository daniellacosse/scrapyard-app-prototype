class Effect < ActiveRecord::Base
	has_many :scraper_modules
	has_many :scraps
end
