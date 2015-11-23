class Blueprint < ActiveRecord::Base
	has_many :blueprint_holds
	has_one :scrapper_module
	has_many :blueprint_requirements
	has_many :requirements, through: :blueprint_requirements

	def cost
		rank * Math.log(requirements.map(&:difficulty).sum)
	end
end
