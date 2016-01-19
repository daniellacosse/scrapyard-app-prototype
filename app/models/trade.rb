class Trade < ActiveRecord::Base
  belongs_to :game_state

  def make
    proposing_state_id = proposing_state.id
    state_id = game_state.id

    transaction do
      ScrapHold.find(scrap_hold_cost).update(game_state_id: proposing_state_id)
      ScrapHold.find(proposing_player_scrap_hold_cost).update(game_state_id: state_id)

      BlueprintHold.find(blueprint_hold_cost).update(game_state_id: proposing_state_id)
      BlueprintHold.find(proposing_player_blueprint_hold_cost).update(game_state_id: state_id)

      ModuleHold.find(module_hold_cost).update(game_state_id: proposing_state_id)
      ModuleHold.find(proposing_player_module_hold_cost).update(game_state_id: state_id)

      game_state.update(game_state.raw + proposing_player_raw_cost - raw_cost)
      proposing_state.update(proposing_state.raw - raw_cost + proposing_player_raw_cost)
    end
  end

  def proposing_player
    proposing_state.player
  end

  def proposing_state
    GameState.find(proposing_player_state_id)
  end
end
