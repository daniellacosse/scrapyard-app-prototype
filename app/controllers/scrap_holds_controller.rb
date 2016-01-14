class ScrapHoldsController < ApplicationController
  before_action :authenticate_player!

  def create
    @game_state = GameState.find(params[:game_state_id])

    hold_params[:batch_ids]
      .split(/\s*[^a-zA-Z0-9]\s+|\s+/)
      .reject(&:empty?)
      .each do |id|
        @game_state.scrap_holds << ScrapHold.create(scrap_id: id.to_i)
      end

    @game_state.save
    render "/game_states/show"
  end

  def destroy
    @scrap_hold = ScrapHold.find(params[:id])
    @game_state = @scrap_hold.game_state

    if params[:sell]
      @scrap_hold.sell
    else
      @scrap_hold.destroy
    end

    render "/game_states/show"
  end

  private
  def hold_params
    params.require(:scrap_hold).permit(:batch_ids)
  end
end
