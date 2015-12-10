class ScrapHoldsController < ApplicationController
  before_action :authenticate_player!

  def destroy
    @scrap_hold = ScrapHold.find(params[:id])

    if @scrap_hold.destroy
      publish_data @scrap_hold.game_state, [ "scraps" ]

      render nothing: true
    end
  end
end
