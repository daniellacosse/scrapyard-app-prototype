class PartTarget < ActiveRecord::Base
	belongs_to :scrapper_module
	belongs_to :target
end
