class ScrapperModule < ActiveRecord::Base
	has_many :weapon_targets
	has_many :targets, through: :weapon_targets

	has_many :module_effects
	has_many :effects, through: :module_effects

	has_many :module_holds

	def add_target(target_data)
		weapon_targets << Target.find_or_create_by(target_data)
	end

	def add_effect(effect_data)
		effects << Effect.find_or_create_by(effect_data)
	end

	def power
		raw_stat_sum = [
			armor, res, (1 / weight), targets.count, weapon_dmg, weapon_acc
		].sum

		true_flags = 0.0
		true_flags += 1.0 if gives_digging
		true_flags += 1.0 if gives_flying

		if weapon_type == "MELEE"
			true_flags += 0.5
		elsif weapon_type == "RANGED"
			true_flags += 1.0
		end

		true_flags = true_flags / 3.0 + 1.0

		raw_stat_sum * (2.0 ** effects.map(&:magnitude).sum) * true_flags
	end

	def pcr
		power / blueprint.cost
	end
end
