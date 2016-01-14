class ScrapHoldsController < ApplicationController
  before_action :authenticate_player!

  def create
    @game_state = GameState.find(params[:game_state_id])

    hold_params[:batch_ids]
      .split(/\s*[^a-zA-Z0-9]\s+|\s+/)
      .reject(&:empty?)
      .each do |id|
        hold = ScrapHold.create(scrap_id: id.to_i)

        if hold.persisted?
          scrap = hold.scrap
          @game_state.scrap_holds << hold
          @game_state.siblings.includes(:blueprints).each do |sibling|
            next if sibling.id == @game_state.id
            matches = sibling.blueprints.to_a.select do |bp|
              !sibling.holds?(scrap) && bp.requires?(scrap)
            end

            if matches.length > 0
              alert_text = <<-HEREDOC
                #{@game_state.player.email} drew a(n) #{scrap.name}!
                (You need one for: #{matches.map(&:name).join(', ')}.)
              HEREDOC

              Message.create(game_state_id: sibling.id, text: alert_text)
            end
          end
        else
          flash[:error] ||= []
          flash[:error] << "Unable to create scrap hold."
        end
      end

    @game_state.save
    redirect_to game_state_path(@game_state)
  end

  def destroy
    @scrap_hold = ScrapHold.find(params[:id])
    @game_state = @scrap_hold.game_state

    if params[:sell]
      @scrap_hold.sell
    else
      @scrap_hold.destroy
    end

    redirect_to game_state_path(@game_state)
  end

  private
  def hold_params
    params.require(:scrap_hold).permit(:batch_ids)
  end
end
