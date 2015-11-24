class Scrap < ActiveRecord::Base
	has_many :scrap_holds
	has_one :effect
	has_many :scrap_classes
	has_many :class_types, through: :scrap_classes

	def rarity
		# TODO: rarity (by class & name)
		1
	end

	def add_class
	end

	def add_effect
	end
end
