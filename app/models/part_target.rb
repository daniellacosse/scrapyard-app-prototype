class PartTarget < ActiveRecord::Base
	belongs_to :part
	belongs_to :target
end
