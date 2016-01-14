class BlueprintHoldsController < ApplicationController
  before_action :authenticate_player!

  def create
    @game_state = GameState.find(params[:game_state_id])
    @game = @game_state.game

    @blueprint_hold.batch_ids
      .split(/\s*[^a-zA-Z0-9]\s+|\s+/)
      .reject(&:empty?)
      .each do |id|
        @game_state.blueprint_holds << BlueprintHold.create(
          blueprint_id: id.to_i, game_id: @game.id
        )
      end

    @game_state.save
    render "/game_states/show"
  end

  def destroy
    @blueprint_hold = BlueprintHold.find(params[:id])

    @game_state = @blueprint_hold.game_state

    if params[:build]
      ModuleHold.create(
        scrapper_module_id: @blueprint_hold.blueprint.scrapper_module.id,
        game_state_id: @game_state.id
      )
    end

    @blueprint_hold.destroy
    render "/game_states/show"
  end
end
