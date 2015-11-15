class Scrap < ActiveRecord::Base
	has_many :scrap_holds
	has_one :effect

	def rarity
		# TODO: rarity (by class & name)
		1
	end
end
