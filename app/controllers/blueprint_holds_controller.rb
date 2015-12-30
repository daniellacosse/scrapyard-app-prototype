class BlueprintHoldsController < ApplicationController
  before_action :authenticate_player!

  def show
    @blueprint_hold = BlueprintHold.find(params[:id])
    @constructions = blueprint_hold.possible_constructions
  end

  def destroy
    @blueprint_hold = BlueprintHold.find(params[:id])

    if @blueprint_hold.destroy
      @blueprint_hold.game_state.siblings.each { |state| publish_data state, [ "available_blueprints", "blueprints"] }

      render nothing: true
    end
  end
end
