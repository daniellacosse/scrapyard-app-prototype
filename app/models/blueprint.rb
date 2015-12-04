class Blueprint < ActiveRecord::Base
	has_one :scrapper_module

	has_many :blueprint_requirements
	has_many :requirements, through: :blueprint_requirements

	has_many :blueprint_holds

	def add_requirement(requirement_data)
		requirement = Requirement.create(
			override_value: requirement_data[:override_value]
		)

		requirement_data[:options].each do |option_string|
			option_stub = Option.create()

			option_string.split(/ & /).each do |ingredient|
				if /^\(\d+\)/ =~ ingredient
					ingredient_name = ingredient.match(/^\(\d+\)\s+(.+)/)[1]
					ingredient_count = ingredient.match(/^\((\d+)\)/)[1].to_i
				else
					ingredient_name = ingredient
				end

				if found_scrap = ClassType.find_by_name(ingredient_name)
					option_stub.scrap_options << ScrapOption.create(
						count: ingredient_count,
						scrap_id: found_scrap.id
					)
				elsif found_class = Scrap.find_by_name(ingredient_name)
					option_stub.class_options << ClassOption.create(
						count: ingredient_count,
						class_type_id: found_class.id
					)
				else
					throw "Unknown Scrap or Class #{ingredient_name}!"
				end
			end

			requirement.options << option_stub
		end

		requirements << requirement
	end

	def cost
		rank * Math.log(requirements.map(&:difficulty).sum)
	end

	def name
		scrapper_module.name
	end

	def to_json
		{ name: name, id: id }.to_json
	end
end
