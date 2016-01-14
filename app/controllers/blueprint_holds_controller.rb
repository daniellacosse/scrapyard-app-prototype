class BlueprintHoldsController < ApplicationController
  before_action :authenticate_player!

  def destroy
    @blueprint_hold = BlueprintHold.find(params[:id])

    @game_state = @blueprint_hold.game_state

    @blueprint_hold.destroy

    render "/game_states/show"
  end
end
