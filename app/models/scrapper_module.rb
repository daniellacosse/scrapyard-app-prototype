class ScrapperModule < ActiveRecord::Base
	has_many :weapon_targets
	has_many :targets, through: :weapon_targets

	has_many :module_effects
	has_many :effects, through: :module_effects

	has_many :module_holds

	def add_target(target_data)
		targets << Target.find_or_create_by(name: target_data)
	end

	def add_effect(effect_data)
		effects << Effect.find_or_create_by(effect_data)
	end

	def power
		inverse_weight = 1 / weight.to_i if weight.to_i > 0

		raw_stat_sum = [
			armor, res, inverse_weight, targets.count, weapon_dmg, weapon_acc
		].map(&:to_i).sum

		true_flags = 0.0
		true_flags += 1.0 if gives_digging
		true_flags += 1.0 if gives_flying

		if weapon == "MELEE"
			true_flags += 0.5
		elsif weapon == "RANGED"
			true_flags += 1.0
		end

		true_flags = true_flags / 3.0 + 1.0

		raw_stat_sum * (2.0 ** effects.map(&:magnitude).sum) * true_flags
	end
end
