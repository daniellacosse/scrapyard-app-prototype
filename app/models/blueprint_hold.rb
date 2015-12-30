class BlueprintHold < ActiveRecord::Base
	belongs_to :game_state
	belongs_to :blueprint

	def possible_constructions
		recursive_constructions(
			requirements, { raw: game_state.raw, scraps: scraps }
		).map do |construction|
			{
				blob: construction.to_json,
				pretty: <<-HEREDOC
					#{construction[:raw]} raw materials and the following:
					#{construction[:scraps].join("\n")}
				HEREDOC
			}
		end
	end

	def missing_parts
		# ...
	end

	def name
		blueprint.name
	end

	def requirements
		blueprint.requirements
	end

	def player
		game_state.player
	end

	def scraps
		game_state.scrap_holds.map(&:scrap)
	end

	private

	# TODO
	def recursive_constructions(requirements, resources, construction)
		return construction if requirements.length == 0

		present_requirement = requirements.shift
		construction = { raw: 0, scraps: [] } if !construction

		possible_outcomes = []
		present_requirement.options.each do |option|

			possible_outcome = { scraps: [] }
			# determine possible outcomes for each option
			if option.scraps.all? { |s| resources[:scraps].include? s }
				possible_outcome[:scraps] += option.scraps.map(&:name)
			end

			option.class_types.each do |class_type|
				# get list of satisfactory scraps

			end
		end

		if present_requirement.override_value <= construction[:raw]
			possible_outcomes << { raw: present_requirement.override_value }
		end

		return nil if possible_outcomes.length == 0

		possible_outcomes.map do |outcome|
			# dup construction and resources
			remaining_resources = resources.dup
			duped_construction = construction.dup

			# transfer from duped resources to duped construction
			duped_construction[:raw] += outcome[:raw].to_i
			duped_construction[:scraps] += outcome[:scraps]

			remaining_resources[:raw] -= outcome[:raw].to_i
			remaining_resources[:scraps] -= outcome[:scraps]

			recursive_constructions(
				requirements, remaining_resources, duped_construction
			)
		end.flatten.compact
	end
end
