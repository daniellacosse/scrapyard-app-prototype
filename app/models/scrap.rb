class Scrap < ActiveRecord::Base
	has_many :scrap_classes
	has_many :class_types, through: :scrap_classes

	has_many :scrap_options
	has_many :options, through: :scrap_options

	has_many :scrap_holds

	def add_class(class_name)
		class_types << ClassType.find_or_create_by(name: class_name)
	end

	def rarity
		# TODO: rarity (by name)
		1
	end
end
