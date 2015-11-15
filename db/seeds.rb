# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

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

Blueprint.create make_collec_from_google BLUEPRINT_GSHEET_ID
Scrap.create make_collec_from_google SCRAP_GSHEET_ID
Module.create make_collec_from_google PART_GSHEET_ID

# TODO: sub-collections:
	# blueprint: requirements => options
	# scrap: effect
	# module: targets, effects
