class BlueprintHold < ActiveRecord::Base
  attr_accessor :batch_ids

  belongs_to :game_state
  belongs_to :blueprint

  validates_uniqueness_of :blueprint_id, scope: :game_id

  def build_options
    my_resource_pool = ResourcePool.new(game_state: game_state)
    requirement_array = blueprint.requirements.to_a
    valid_builds = []

    if game_state.contestant.name == "Anansi"
      new_requirement_length = [2, requirement_array.length - 1].max

      valid_builds = requirement_array.combination(new_requirement_length).map do |sub_requirements|
        build_list(ResourcePool.new(game_state: game_state), sub_requirements).select do |build|
          build.met_requirements == new_requirement_length
        end
      end.flatten

    else
      valid_builds = build_list(my_resource_pool, requirement_array).select do |build|
        build.met_requirements == blueprint.requirements.length
      end
    end

    valid_builds
    .uniq do |build|
      "raw:#{build.raw}.scraps:#{build.scraps.map(&:name).sort.join(',')}"
    end
    .sort { |build| build.raw.to_i }
  end

  private

  def build_list(resource_pool, requirements, build_pool = ResourcePool.new)
    return [build_pool] if requirements.length <= 0
    return [build_pool] if resource_pool.empty?

    build_branches = []

    requirement = requirements.first
    override_pool = ResourcePool.new(raw: requirement.override_value)

    # check override
    if resource_pool.raw.to_i >= override_pool.raw.to_i
      build_branch = build_pool + override_pool
      leftovers = resource_pool - override_pool

      build_branch.met_requirements += 1

      build_branches << build_list(
        leftovers, requirements[1..-1].dup, build_branch
      )
    end

    requirement.options.each do |option|
      class_list = [].tap do |_cl|
        option.class_options.each do |cop|
          (cop.count || 1).times { _cl << cop.class_type }
        end
      end

      option_pool = ResourcePool.new(
        scraps: option.scraps.to_a,
        scrap_types: class_list
      )

      # check all fits
      resource_pool.list_fits(option_pool).each do |option_fit|
        build_branch = build_pool + option_fit
        leftovers = resource_pool - option_fit

        build_branch.met_requirements += 1

        build_branches << build_list(
          leftovers, requirements[1..-1].dup, build_branch
        )
      end
    end

    build_branches.flatten
  end
end

class ResourcePool
  attr_accessor :met_requirements
  attr_reader :scraps, :scrap_types, :raw

  def self.permute_over_scrap_types(scrap_types, source_pool, build_pool = ResourcePool.new)
    return [build_pool] if scrap_types.length <= 0

    scrap_type = scrap_types.shift
    scrap_type_branch = []

    source_pool.scrap_type_matches(scrap_type).each do |matching_scrap|
      matching_scrap_pool = ResourcePool.new(scraps: [matching_scrap])

      next_pool = build_pool + matching_scrap_pool
      remainder_pool = source_pool - matching_scrap_pool

      next_pool.met_requirements += 1

      scrap_type_branch << ResourcePool.permute_over_scrap_types(
        scrap_types.dup, remainder_pool, next_pool
      )
    end

    scrap_type_branch.flatten
  end

  def initialize(params = {})
    @met_requirements = params[:met_requirements] || 0

    if params[:game_state]
      @scraps = params[:game_state].scrap_holds.map(&:scrap).to_a
      @scrap_types = []
      @raw = params[:game_state].raw
    elsif params[:option]
      @raw = 0
      @scraps = params[:option].scraps.to_a
      params[:option].class_options.to_a.each do |class_option|
        class_option.count.times { @scrap_types << class_option.class_type }
      end
    else
      @scraps = params[:scraps] || []
      @scrap_types = params[:scrap_types] || []
      @raw = params[:raw] || 0
    end
  end

  def +(pool)
    ResourcePool.new(
      met_requirements: met_requirements,
      raw: raw.to_i + pool.raw.to_i,
      scrap_types: scrap_types + pool.scrap_types,
      scraps: scraps + pool.scraps
    )
  end

  def -(pool)
    new_scraps = scraps.dup
    new_scrap_types = scrap_types.dup

    pool.scrap_types.each do |_type|
      new_scrap_types.delete_at(new_scrap_types.index(scrap))
    end

    pool.scraps.each do |scrap|
      new_scraps.delete_at(new_scraps.index(scrap))
    end

    ResourcePool.new(
      met_requirements: met_requirements,
      raw: raw.to_i - pool.raw.to_i,
      scrap_types: new_scrap_types,
      scraps: new_scraps
    )
  end

  def scrap_type_matches(type)
    scraps.select do |scrap|
      scrap.class_types.to_a.map(&:name).include? type.name
    end
  end

  def list_fits(pool)
    return [] unless pool.scraps.all? { |scrap| scraps.include? scrap }

    # recurse over scrap_types
    # pass in scrap_types, truncated pool, ResourcePool w/ scraps
    scrap_pool = ResourcePool.new(scraps: pool.scraps)
    remainder = self - scrap_pool

    return [scrap_pool] if remainder.empty?

    ResourcePool
      .permute_over_scrap_types(pool.scrap_types.dup, remainder)
      .select do |result_pool|
        result_pool.met_requirements == pool.scrap_types.length
      end
      .map { |fit| fit + scrap_pool }
  end

  def empty?
    scraps.length == 0 && raw == 0 && scrap_types.length == 0
  end

  # TODO: fix
  def length
    1
  end
end
