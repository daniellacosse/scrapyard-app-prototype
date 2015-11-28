### UTILITIES ###

require "open-uri"
require "csv"

BLUEPRINT_GSHEET_ID = "1U3qdbXnyi2oVsmM4VfmC3pEiZeY1GpQtC-8oYHZXJJ0"
MODULE_GSHEET_ID = "16jBtmovxFQTLET0vslgcNN_nIySaaQskF-Sus9UO1mA"
SCRAP_GSHEET_ID = "1Psrg3zjlt8-x7AiYlKRVpy9dxsaCtaX0QOBHy67Nvug"

def make_collec_from_google(id)
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

class String
	def split_on_comma
		split /,\s*/
	end

	def parse_on_effect
		split(/,\s*\(\d*[+-]\)/).map do |effect_str|
			{
				description: effect_str.match(/^\([+-]\d*\)\s*(.*)/)[1],
				magnitude: (effect_str.match(/^\([+-](\d*)\)/)[1] || 1).to_i
			}
		end
	end

	def to_bool
      result = false
      result = (!self.nil? && !(self.downcase.squish == "false") && (self.downcase.squish == "true" || self != "0" || self == "1"))

      result
    end
end

### OFFLINE TEST ###
blueprints = [
	{
		"name" => "module1",
		"rq1" => "class1, (2) class2",
		"rq1_val" => "3",
		"rq2" => "scrap1",
		"rq2_val" => "7"
	}, {
		"name" => "module2",
		"rq1" => "class1 & class2, (3) class2",
		"rq1_val" => "6",
		"rq2" => "scrap2",
		"rq2_val" => "8"
	}
]

modules = [
	{
		"name" => "module1",
		"mod_type" => "ARM",
		"armor" => "6",
		"res" => "3",
		"weight" => "2",
		"gives_digging" => "FALSE",
		"gives_flying" => "TRUE",
		"weapon" => "MELEE",
		"weapon_targets" => "Arm, Leg",
		"weapon_dmg" => "3",
		"weapon_acc" => "12",
		"effects" => "(+) good effect"
	}, {
		"name" => "module2",
		"mod_type" => "LEG",
		"armor" => "4",
		"res" => "3",
		"weight" => "2",
		"gives_digging" => "TRUE",
		"gives_flying" => "FALSE",
		"weapon" => nil,
		"weapon_targets" => nil,
		"weapon_dmg" => nil,
		"weapon_acc" => nil,
		"effects" => "(+) good effect"
	}
]

scraps = [
	{
		"name" => "scrap1",
		"classes" => "class1",
		"value" => "1",
		"effects" => nil
	}, {
		"name" => "scrap2",
		"classes" => "class1",
		"value" => "2",
		"effects" => "(+) good effect"
	}, {
		"name" => "scrap3",
		"classes" => "class1, class2",
		"value" => "3",
		"effects" => nil
	}
]

### SCRIPT BEGIN ###
# blueprints = make_collec_from_google BLUEPRINT_GSHEET_ID
# modules = make_collec_from_google MODULE_GSHEET_ID
# scraps = make_collec_from_google SCRAP_GSHEET_ID

scraps.each do |scrap_data|
	scrap = Scrap.create name: scrap_data["name"], value: scrap_data["value"]

	scrap_data["classes"].split_on_comma.each { |c| scrap.add_class c }
	if scrap_data["effects"]
		scrap_data["effects"].parse_on_effect.each { |e| scrap.add_effect e }
	end
end

modules.each do |mod_data|
	mod = ScrapperModule.create({
		name: mod_data["name"],
		mod_type: mod_data["mod_type"],
		armor: mod_data["armor"].to_i,
		res: mod_data["res"].to_i,
		weight: mod_data["weight"].to_i,
		gives_digging: mod_data["gives_digging"].to_bool,
		gives_flying: mod_data["gives_flying"].to_bool,
		weapon: mod_data["weapon"],
		weapon_dmg: mod_data["weapon_dmg"].to_i,
		weapon_acc: mod_data["weapon_acc"].to_i
	})

	if mod_data["weapon_targets"]
		mod_data["weapon_targets"].split_on_comma.each { |t| mod.add_target t }
	end

	if mod_data["effects"]
		mod_data["effects"].parse_on_effect.each { |e| mod.add_effect e }
	end

	blueprint_data = blueprints.find { |b| b["name"] == mod.name }
	blueprint = Blueprint.create scrapper_module_id: mod.id

	5.times do |i|
		req_key, req_val_key = "rq#{i+1}", "rq#{i+1}_val"

		if blueprint_data[req_key] && blueprint_data[req_val_key]
			blueprint.add_requirement(
				options: blueprint_data[req_key].split_on_comma,
				override_value: blueprint_data[req_val_key]
			)
		end
	end
end
