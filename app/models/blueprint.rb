class Blueprint < ActiveRecord::Base
	has_many :blueprint_holds
	has_one :part
end
