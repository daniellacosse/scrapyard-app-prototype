class BlueprintHold < ActiveRecord::Base
	attr_accessor :batch_ids

	belongs_to :game_state
	belongs_to :blueprint

	validates_uniqueness_of :blueprint_id, scope: :game_id

	def build_options
		my_resource_pool = ResourcePool.new(game_state: game_state)

		build_list my_resource_pool, blueprint.requirements.to_a
	end

	private
	def build_list(resource_pool, requirements, build_pool = ResourcePool.new)
		return build_pool if requirements.length <= 0

		build_branches = []

		requirement = requirements.first
		override_pool = ResourcePool.new(raw: requirement.override_value)

		requirement.options.each do |option|
			option_pool = ResourcePool.new(option: option)

			if resource_pool.contains? option_pool
				build_branch = build_pool + option_pool
				leftovers = resource_pool - option_pool

				build_branches << build_list(
					leftovers, requirements[1..-1], build_branch
				)
			end

			if resource_pool.contains? override_pool
				build_branch = build_pool + override_pool
				leftovers = resource_pool - override_pool

				build_branches << build_list(
					leftovers, requirements[1..-1], build_branch
				)
			end
		end

		build_branches.flatten
	end
end

class ResourcePool
	attr_reader :scraps, :raw

	def initialize(params = {})
		if params[:game_state]
			@scraps = params[:game_state].scrap_holds.includes(:scrap).to_a
			@raw = params[:game_state].raw
		elsif params[:option]
			@scraps = params[:option].scraps.to_a + params[:option].class_types.to_a
		else
			@scraps = params[:scraps] || []
			@raw = params[:raw] || 0
		end
	end

	def +(pool)
		ResourcePool.new(raw: raw.to_i + pool.raw.to_i, scraps: scraps + pool.scraps)
	end

	def -(pool)
		ResourcePool.new(raw: raw.to_i - pool.raw.to_i, scraps: scraps - pool.scraps)
	end

	def contains?(pool)
		is_contain = raw.to_i >= pool.raw.to_i

		# TODO: class comparisons, multiple of scrap/class
		is_contain &= pool.scraps.all? { |scrap| scraps.map(&:scrap).include? scrap }

		is_contain
	end

	# TODO: fix
	def length
		1
	end
end
