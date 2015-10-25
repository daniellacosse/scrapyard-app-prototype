class Option < ActiveRecord::Base
	belongs_to :requirement
	has_many :scrap_options
	has_many :scraps, through: :scrap_options

	def cost
		option_value, option_rarity = 0, 1

		option.scrap_option.each do |scrap_option|
			scrap = scrap_option.scrap

			option_value += scrap_option.count * scrap.value
			option_rarity *= scrap_option.count * scrap.rarity
		end

		option_value / option_rarity
	end
end
