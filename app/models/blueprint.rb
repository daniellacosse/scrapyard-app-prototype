class Blueprint < ActiveRecord::Base
	has_many :blueprint_holds
	has_one :part
	has_many :requirements

	def cost
		rank * Math.log requirements.map(&:difficulty).sum
	end
end
