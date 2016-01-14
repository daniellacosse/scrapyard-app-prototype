class ScrapHoldsController < ApplicationController
  before_action :authenticate_player!

  def destroy
    @scrap_hold = ScrapHold.find(params[:id])

    @game_state = @scrap_hold.game_state

    @scrap_hold.destroy

    render "/game_states/show"
  end
end
