class ClassOption < ActiveRecord::Base
	belongs_to :option
	belongs_to :class_type
end
