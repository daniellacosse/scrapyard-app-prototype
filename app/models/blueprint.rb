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

			option_string.split(", ").each do |ingredient|
				if /^.+\(\d+\)/ =~ ingredient
					ingredient_name = ingredient.match(/^(.+)\s+\(\d+\)/)[1]
					ingredient_count = ingredient.match(/^.+\((\d+)\)/)[1].to_i
				else
					ingredient_name = ingredient
				end

				if class_match = ingredient_name.match(/\[(.*)\]/)
					found_class = ClassType.find_by_name(class_match[1])

					unless found_class
						puts ingredient_name
						byebug
					end

					option_stub.class_options << ClassOption.create(
						count: ingredient_count,
						class_type_id: found_class.id
					)
				else
					found_scrap = Scrap.find_by_name(ingredient_name)

					unless found_scrap
						puts ingredient_name
						byebug
					end

					option_stub.scrap_options << ScrapOption.create(
						count: ingredient_count,
						scrap_id: found_scrap.id
					)
				end
			end

			requirement.options << option_stub
		end

		requirements << requirement
	end

	def power
		scrapper_module.power
	end

	def name
		scrapper_module.name
	end

	def requires?(scrap)
		match = false

		requirements.each do |requirement|
			next if match
			requirement.options.each do |option|
				next if match
				match = true if option.scraps.include? scrap
			end
		end

		match
	end
end
