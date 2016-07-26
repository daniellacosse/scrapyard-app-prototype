class Option < ActiveRecord::Base
	has_many :requirement_options
	has_many :requirements, through: :requirement_options

	has_many :scrap_options
	has_many :scraps, through: :scrap_options

	has_many :class_options
	has_many :class_types, through: :class_options
end
