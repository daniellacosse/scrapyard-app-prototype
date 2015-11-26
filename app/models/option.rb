class Option < ActiveRecord::Base
	has_many :requirement_options
	has_many :requirements, through: :requirement_options

	has_many :scrap_options
	has_many :scraps, through: :scrap_options

	has_many :class_options
	has_many :class_types, through: :class_options

	def cost
		option_value, option_rarity = 0, 1

		scrap_options.each do |option|
			option_value += option.count * option.scrap.value
			option_rarity *= option.count * option.scrap.rarity
		end

		class_option.each do |option|
			option_value += option.count * option.class_type.scraps.map(&:value).mean
			option_rarity *= option.count * option.class_type.scraps.map(&:rarity).sum
		end

		option_value / option_rarity
	end
end
