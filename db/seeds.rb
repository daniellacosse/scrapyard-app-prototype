### UTILITIES ###

require "open-uri"
require "csv"

BLUEPRINT_GSHEET_ID = "1U3qdbXnyi2oVsmM4VfmC3pEiZeY1GpQtC-8oYHZXJJ0"
SCRAP_GSHEET_ID = "16jBtmovxFQTLET0vslgcNN_nIySaaQskF-Sus9UO1mA"
PART_GSHEET_ID = "1Psrg3zjlt8-x7AiYlKRVpy9dxsaCtaX0QOBHy67Nvug"

def make_collec_from_google (id)
	result = []

	buffer = CSV.parse(
		open("https://docs.google.com/spreadsheets/d/#{id}/export?format=csv").read
	)

	headers = buffer.shift

	buffer.each do |row|
		result << {}.tap do |obj|
			headers.each_with_index { |header, i| obj[header] = row[i] }
		end
	end

	result
end

def create_blueprint_requirement(print_req_data)

end

def lazily_create_effect(effect_data)

end

def create_module_effect(effect_data)

end

def create_module_target(target_data)

end

def create_scrap_class(class_data)

end

### SCRIPT BEGIN ###

blueprints = make_collec_from_google BLUEPRINT_GSHEET_ID
scraps = make_collec_from_google SCRAP_GSHEET_ID
modules = make_collec_from_google PART_GSHEET_ID

# make sub-collections:

# module: targets, effects
modules.map! do |module_data|
	mod = ScrapperModule.create {

	}

	mod_data["targets"].split(/,|, /).each do |target_data|
		create_module_target target_data, mod.id
	end

	mod_data["effects"].split(/,|, /).each do |effect_data|
		create_module_effect effect_data, mod.id
	end
end

# blueprint: requirements => options
blueprints.each do |blueprint_data|
	Blueprint.create {
		module_id: print["id"],
		name: print["name"],
		rank: print["rank"]
	}

	if blueprint_data["requirement1"] && blueprint_data["requirement1_val"]
		create_blueprint_requirement(
			options: blueprint_data["requirement1"],
			override_value: blueprint_data["requirement1_val"]
		)
	end

	if blueprint_data["requirement2"] && blueprint_data["requirement2_val"]
		create_blueprint_requirement(
			options: blueprint_data["requirement2"],
			override_value: blueprint_data["requirement2_val"]
		)
	end

	if blueprint_data["requirement3"] && blueprint_data["requirement3_val"]
		create_blueprint_requirement(
			options: blueprint_data["requirement3"],
			override_value: blueprint_data["requirement3_val"]
		)
	end

	if blueprint_data["requirement4"] && blueprint_data["requirement4_val"]
		create_blueprint_requirement(
			options: blueprint_data["requirement4"],
			override_value: blueprint_data["requirement4_val"]
		)
	end

	if blueprint_data["requirement5"] && blueprint_data["requirement5_val"]
		create_blueprint_requirement(
			options: blueprint_data["requirement5"],
			override_value: blueprint_data["requirement5_val"]
		)
	end
end

# scrap: effect && class
scraps.each do |scrap_data|
	scrap = Scrap.create {
		effect_id: lazily_create_effect scrap_data["effect"],
		value: scrap_data["value"],
		name: scrap_data["name"]
	}

	scrap_data["classes"].split(/,|, /).each do |effect|
		create_module_effect effect, scrap.id
	end
end
