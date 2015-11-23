class Option < ActiveRecord::Base
	has_many :requirement_options
	has_many :requirements, through: :requirement_options
	has_many :scrap_options
	has_many :scraps, through: :scrap_options

	def cost
		option_value, option_rarity = 0, 1

		scrap_options.each do |option|
			option_value += option.count * option.scrap.value
			option_rarity *= option.count * option.scrap.rarity
		end

		option_value / option_rarity
	end
end
