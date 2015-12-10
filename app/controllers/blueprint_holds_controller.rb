class BlueprintHoldsController < ApplicationController
  before_action :authenticate_player!

  def destroy
    @blueprint_hold = BlueprintHold.find(params[:id])

    if @blueprint_hold.destroy
      @blueprint_hold.game_state.siblings.each { |state| publish_data state, [ "available_blueprints", "blueprints"] }

      render nothing: true
    end
  end
end
