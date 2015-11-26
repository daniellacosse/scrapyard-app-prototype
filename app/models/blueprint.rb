class Blueprint < ActiveRecord::Base
	has_one :scrapper_module

	has_many :blueprint_requirements
	has_many :requirements, through: :blueprint_requirements

	has_many :blueprint_holds

	def add_requirement(requirement_data)
		requirement = Requirement.find_or_create_by(requirement_data)

		requirement_data[:options].each do |option_string|
			option_stub = Option.create()

			option_string.split(/ & /).each do |ingredient|
				ingredient_name = ingredient.match(/^\(\d+\)\s+(.+)|^(.+)/)[1]
				ingredient_count = ingredient.match(/^(\d+)/)[1].to_i || 1

				if found_scrap = ClassType.find(name: ingredient_name)
					option_stub.scrap_options << ScrapOption.create(
						count: ingredient_count,
						scrap_id: found_scrap.id
					)
				elsif found_class = Scrap.find(name: ingredient_name)
					option_stub.class_options << ClassOption.create(
						count: ingredient_count,
						class_type_id: found_class.id
					)
				else throw "Unknown Scrap or Class #{ingredient_name}!"
			end

			requirement.options << option_stub
		end

		requirements << requirement
	end

	def cost
		rank * Math.log(requirements.map(&:difficulty).sum)
	end
end
