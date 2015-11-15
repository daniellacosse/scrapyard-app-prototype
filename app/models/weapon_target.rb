class PartTarget < ActiveRecord::Base
	belongs_to :module
	belongs_to :target
end
