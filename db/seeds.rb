### UTILITIES ###
require "open-uri"
require "csv"

def secret(secret_name)
	Rails.application.secrets[secret_name]
end

def make_collec_from_csv(url)
	result = []

	buffer = CSV.parse(
		open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
	)

	headers = buffer.shift

	buffer.each do |row|
		result << {}.tap do |obj|
			headers.each_with_index { |header, i| obj[header] = row[i] }
		end
	end

	result
end

def make_collec_from_google(id)
	make_collec_from_csv("https://docs.google.com/spreadsheets/d/#{id}/export?format=csv")
end

### SCRIPT BEGIN ###
weapons = make_collec_from_google(secret(:weapon_gsheet_id)).map do |weapon|
	weapon["type"] = "WPN"
	weapon["class_id"] = weapon["wpn_id"]
	weapon
end

limbs = make_collec_from_google(secret(:limb_gsheeet_id)).map do |limb|
	limb["type"] = "LMB"
	limb["class_id"] = limb["lmb_id"]
	limb
end

addons = make_collec_from_google(secret(:add_gsheet_id)).map do |add|
	add["type"] = "ADD"
	add["class_id"] = add["add_id"]
	add
end

modules = weapons + limbs + addons
scraps = make_collec_from_google secret(:scrap_gsheet_id)
blueprints = make_collec_from_csv secret(:blueprint_process_csv_url)
contestants = make_collec_from_google secret(:contestant_gsheet_id)

contestants.each do |contestant_data|
	Contestant.create({
		name: contestant_data["name"],
		eng_lvl: contestant_data["eng_lvl"],
		body_lvl: contestant_data["body_lvl"],
		pilot_lvl: contestant_data["pilot_lvl"],
		chassis_lvl: contestant_data["chassis_lvl"]
	})
end

scraps.each do |scrap_data|
	scrap = Scrap.create name: scrap_data["name"]

	scrap_classes = scrap_data["classes"]

	scrap_classes.split(", ").each { |c| scrap.add_class c } if scrap_classes
end

modules.each do |mod_data|
	mod = ScrapperModule.create(
		armor: mod_data["armor"].to_i,
		damage_type: mod_data["damage_type"], # TODO: damage types
		damage: mod_data["damage"].to_i,
		mobility: mod_data["mobility"],
		name: mod_data["name"],
		range: mod_data["range"].to_i,
		resilience: mod_data["resilience"].to_i,
		spread: mod_data["spread"].to_i,
		text: mod_data["text"],
		module_class: mod_data["type"], # TODO: subtypes
		class_id: mod_data["class_id"].to_i,
		weight: mod_data["weight"].to_i
	)

	blueprint_data = blueprints.find { |b| b["name"] == mod.name }
	throw "blueprint doesn't exist! try rerunning the deck scripts or resetting the google drive id for the blueprint csv" unless !!blueprint_data
	blueprint = Blueprint.create(
		scrapper_module_id: mod.id,
		rank: blueprint_data["rank"]
	)

	mod.blueprint_id = blueprint.id
	mod.save

	5.times do |i|
		req_key, req_val_key = "rq#{i+1}", "rq#{i+1}_buyout"

		if blueprint_data[req_key] && blueprint_data[req_val_key]
			blueprint.add_requirement(
				options: blueprint_data[req_key].split("\n"),
				override_value: blueprint_data[req_val_key]
			)
		end
	end
end
