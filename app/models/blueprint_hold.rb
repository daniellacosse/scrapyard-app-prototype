class BlueprintHold < ActiveRecord::Base
	attr_accessor :batch_ids

	belongs_to :game_state
	belongs_to :blueprint

	validates_uniqueness_of :blueprint_id, scope: :game_id

	def build_options
		resource_pool = ResourcePool.new(game_state: game_state)

		build_list resource_pool, blueprint.requirements, ResourcePool.new
	end

	private
	def build_list(resource_pool, requirements, build_pool)
		return build if resources.length <= 0

		build_branches = []

		requirements.first.options.each do |option|
			option_pool = ResourcePool.new(option: option)

			# close, but not quite. this doesn't do classes (that's really the kicker)
			if resource_pool.contains? option_pool
				build_branch = build_pool + option_pool
				leftovers = resource_pool - option_pool

				build_branches << build_list(
					leftovers, requirements[1..-1], build_branch
				)
			end
		end

		build_branches.flatten
	end
end

class ResourcePool
	def initialize(params)
		if params[:game_state]
			@scraps = params[:game_state].scrap_holds.include(:scrap)
			@raw = params[:game_state].raw
		elsif params[:option]
			@scraps = params[:option].scraps + params[:option].class_types
		else
			@scraps = params[:scraps] || []
			@raw = params[:raw] || 0
		end
	end

	def +(pool)
		new(raw: raw + pool.raw, scraps: scraps + pool.scraps)
	end

	def -(pool)
		new(raw: raw - pool.raw, scraps: scraps - pool.scraps)
	end

	def contains?(pool)
		is_contain = raw > pool.raw

		# still doesn't do class comparisons
		is_contain &= pool.scraps.all? { |scrap| scraps.include? scrap }

		is_contain
	end
end
