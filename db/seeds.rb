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

### SCRIPT BEGIN ###
blueprints = make_collec_from_google BLUEPRINT_GSHEET_ID
scraps = make_collec_from_google SCRAP_GSHEET_ID
modules = make_collec_from_google PART_GSHEET_ID

modules.each do |module_data|
	mod = ScrapperModule.create module_data

	mod_data["targets"].split(/,|, /).each { |t| mod.add_target t }
	mod_data["effects"].split(/,|, /).each { |e| mod.add_effect e }
end

blueprints.each do |blueprint_data|
	blueprint = Blueprint.create(
		module_id: blueprint_data["id"],
		name: blueprint_data["name"],
		rank: blueprint_data["rank"]
	)

	5.times do |i|
		req_key = "requirement#{i+1}"
		req_val_key = "requirement#{i+1}_val"

		if blueprint_data[req_key] && blueprint_data[req_val_key]
			blueprint.add_requirement(
				options: blueprint_data[req_key],
				override_value: blueprint_data[req_val_key]
			)
		end
	end
end

scraps.each do |scrap_data|
	scrap = Scrap.create scrap_data

	scrap_data["classes"].split(/,|, /).each { |e| scrap.add_class e }
	scrap_data.add_effect scrap_data["effect"]
end
