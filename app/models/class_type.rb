class ClassType < ActiveRecord::Base
	has_many :scrap_classes
	has_many :scraps, through: :scrap_classes
end
