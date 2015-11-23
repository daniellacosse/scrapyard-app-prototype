class Requirement < ActiveRecord::Base
	belongs_to :blueprint
	has_many :requirement_options
	has_many :options, through: :requirement_options

	def difficulty
		option_costs = options.map(&:cost)

		option_costs << override_value

		option_costs.mean
	end
end
