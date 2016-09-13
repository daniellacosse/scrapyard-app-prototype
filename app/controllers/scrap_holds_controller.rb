class ScrapHoldsController < ApplicationController
  before_action :authenticate_player!

  def create
    @game_state = GameState.find(params[:game_state_id])

    hold_params[:batch_ids]
      .split(/,\s?/)
      .reject(&:empty?)
      .each do |id|
        scrap_id, scrap_value = *id.split("-")
        if !!Scrap.find(scrap_id)
          hold = ScrapHold.create(scrap_id: scrap_id.to_i, value: scrap_value.to_i)

          if hold.persisted?
            scrap = hold.scrap
            @game_state.scrap_holds << hold

            @game_state.siblings.includes(:blueprints).each do |sibling|
              matches = []
              alert_text = ""

              if sibling.id == @game_state.id
                matches = sibling.blueprints.to_a.select { |bp| bp.requires?(scrap) }

                alert_text = <<-HEREDOC
Note!: The #{scrap.name} you just drew could be used to help brew any of the following:
#{matches.map(&:name).join(', ')}
                HEREDOC
              else
                matches = sibling.blueprints.to_a.select do |bp|
                  !sibling.holds?(scrap) && bp.requires?(scrap)
                end

                alert_text = <<-HEREDOC
#{@game_state.player.email} drew a(n) #{scrap.name}!
(You need one for: #{matches.map(&:name).join(', ')}.)
HEREDOC
              end

              if matches.length > 0
                Message.create(game_state_id: sibling.id, text: alert_text)
              end
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
