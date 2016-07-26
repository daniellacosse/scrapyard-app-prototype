class ScrapperModule < ActiveRecord::Base
	has_one :blueprint
	has_many :module_holds
end
