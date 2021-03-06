class BlueprintHoldsController < ApplicationController
  before_action :authenticate_player!

  def create
    @game_state = GameState.find(params[:game_state_id])
    @game = @game_state.game

    hold_params[:batch_ids]
      .split(/,\s?/)
      .reject(&:empty?)
      .each do |full_id|
        type, id = *full_id.split("-")

        found_module = ScrapperModule.find_by(module_class: type.upcase, class_id: id.to_i)

        if !!found_module
          hold = BlueprintHold.create(
            blueprint_id: found_module.blueprint_id, game_id: @game.id
          )

          if hold.persisted?
            @game_state.blueprint_holds << hold
          else
            flash[:error] ||= []
            flash[:error] << "Unable to create blueprint hold."
          end
        end
      end

    @game_state.save
    redirect_to game_state_path(@game_state)
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
    redirect_to game_state_path(@game_state)
  end

  private
  def hold_params
    params.require(:blueprint_hold).permit(:batch_ids)
  end
end
