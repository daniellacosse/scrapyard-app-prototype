require "json"

class ModuleHoldsController < ApplicationController
  before_action :set_blueprint_hold, only: [:new, :create]

  def new
    @module_hold = ModuleHold.new(
      game_state_id: @game_state.id,
      scrapper_module_id: @blueprint_hold.blueprint.scrapper_module.id
    )

    @build_options = @blueprint_hold.build_options
  end

  def create
    if @game_state.discard_resources JSON.parse(hold_params[:build])
      ModuleHold.create(
        game_state_id: @game_state.id,
        scrapper_module_id: @blueprint_hold.blueprint.scrapper_module.id
      )

      @blueprint_hold.destroy
    else
      flash[:error] = "Something went wrong. You probably didn't have the right resources."
    end

    redirect_to @game_state
  end

  private
  def hold_params
    params.require(:module_hold).permit(:build)
  end

  def set_blueprint_hold
    @blueprint_hold = BlueprintHold.find(params[:blueprint_hold_id])
    @game_state = @blueprint_hold.game_state
  end
end
