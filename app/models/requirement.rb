class Requirement < ActiveRecord::Base
	belongs_to :blueprint
	has_many :options

	def difficulty
		option_costs = options.map(&:cost)

		option_costs << override_value

		option_costs.mean
	end
end
