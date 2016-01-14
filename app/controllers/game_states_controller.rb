require "json"

ALL_STATES = %w(
  raw players scraps blueprints
  available_blueprints scrapper_modules)

class GameStatesController < ApplicationController
  include ActionController::Live
  before_action :authenticate_player!
  before_action :set_state

  def show
    render :show
  end

  # POST /game_states/:id/discard_raw
  def discard_raw
    @game_state.update raw: @game_state.raw - params[:raw_amount].to_i

    render :show
  end

  # POST /game_states/:id/draw/:card_type
  def draw
    card_id, card_type = params[:card_id], params[:card_type]

    if card_type == "scrap" && !!card_id && card_id != 0
      hold = ScrapHold.create(scrap_id: card_id)
      @game_state.scrap_holds << hold

      @game_state.save
      render :show
    elsif card_type == "blueprint" && !!card_id && card_id != 0
      @game_state.blueprint_holds << BlueprintHold.create(blueprint_id: card_id)

      @game_state.save
      render :show
    else
      flash[:error] = "Card type drawn (#{card_type}) invalid!"
    end
  end

  # POST /game_states/:id/sell/:scrap_hold_id
  def sell
    @scrap_hold = ScrapHold.find params[:scrap_hold_id]

    @scrap_hold.sell

    render :show
  end

  # POST /game_states/:id/build/:blueprint_id
  def build
    @blueprint_hold = BlueprintHold.find params[:blueprint_id]
    tribute = JSON.parse(params[:build_blob]) if params[:build_blob]

    if !!tribute
      @game_state.update(raw: @game_state.raw - tribute["raw"].to_i)
      tribute["scraps"].map do |scrap_name|
        @game_state.scrap_holds
          .to_a
          .find { |sh| sh.scrap.name == scrap_name }
          .destroy
      end.all?
    end

    @blueprint_hold.destroy
    ModuleHold.create(
      scrapper_module_id: @blueprint_hold.blueprint.scrapper_module.id,
      game_state_id: @game_state.id
    )

    render :show
  end

  # POST /game_states/:id/ready
  def ready
    all_ready = @game_state.set_ready

    @game_state = GameState.find params[:id]

    if all_ready
      @game_state.siblings.each { |state| publish_data state, ALL_STATES }

      render :show
    else
      @game_state.siblings.each { |state| publish_data state, [ "players" ] }

      render :show
    end
  end

  # POST /game_states/:id/turn/end
  def end_turn
    @next_player_state = @game_state.siblings.find do |state|
      state.player_number == @game_state.player_number + 1
    end

    unless @next_player_state
      @next_player_state = @game_state.siblings.find do |state|
        state.player_number == 0
      end
    end

    @game_state.update(is_my_turn: false)
    @next_player_state.update(is_my_turn: true)

    @game_state = GameState.find params[:id]
    @next_player_state = GameState.find @next_player_state.id

    @game_state.siblings.each { |state| publish_data state, [ "players" ] }

    render :show
  end

  def destroy
    if @game_state.destroy
      @game_state.siblings.each { |state| publish_data state, [ "players" ] }

      redirect_to games_url
    end
  end

  private

  def set_state
    @game_state = GameState.find params[:id]
  end
end
