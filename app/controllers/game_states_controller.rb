require 'json'

ALL_STATES = %w(
  raw players scraps blueprints
  available_blueprints scrapper_modules)

class GameStatesController < ApplicationController
  include ActionController::Live
  before_action :authenticate_player!
  # before_action :ensure_game_started, only: [
  #   :draw, :trade, :build, :end_turn, :ready
  # ]
  before_action :set_state, only: [
    :show, :edit, :update, :destroy, :draw,
		:trade, :build, :sell, :end_turn, :ready
  ]

  def show
    respond_to do |format|
      format.html { render :show }

      format.json do
        response.headers['Content-Type'] = 'text/event-stream'

        r = Redis.new # url: ENV["REDIS_URL"] || "redis://127.0.0.1:6379/0"
        sub_string = "stream#{@game_state.id}"

        begin
          r.subscribe sub_string do |on|
            on.message do |_event, data|
              response.stream.write "event: update\n"
              response.stream.write "data: #{data}\n\n"
            end
          end
        rescue IOError
        ensure
          r.quit
          response.stream.close
        end
      end
    end
  end

  # POST /game_states/:id/draw/:card_type
  def draw
    card_id = params[:card_id]
    card_type = params[:card_type]

    if card_type == "scrap"
      @game_state.scrap_holds << ScrapHold.create(scrap_id: card_id)
      # TODO: check to see if any player needs that & notify them
    elsif card_type == "blueprint"
      @game_state.blueprint_holds << BlueprintHold.create(blueprint_id: card_id)
    else
      flash[:error] = "Card type drawn (#{card_type}) invalid!"
    end

    handle_response @game_state.save, ["blueprints", "scraps", "available_blueprints"]
  end

  # POST /game_states/:id/sell/:scrap_hold_id
  def sell
    @scrap_hold = ScrapHold.find params[:scrap_hold_id]

    handle_response @scrap_hold.sell, ["raw", "scraps"]
  end

  # POST /game_states/:id/build/:blueprint_id
  def build
    # check if player has blueprint
    # check if player has resources
    # delete blueprint_hold and scrap_holds and create module_hold

    handle_response success
  end

  # POST /game_states/:id/ready
  def ready
    handle_response @game_state.set_ready, ["players"]
  end

  # POST /game_states/:id/turn/end
  def end_turn
    @next_player_state = @game_state.siblings.find do |player|
      player_number == @game_state.player_number + 1
    end

    unless @next_player_state
      @next_player_state = @game_state.siblings.find do |state|
        state.player_number == 1
      end
    end

    @game_state.is_my_turn = false
    @next_player_state.is_my_turn = true

    handle_response @game_state.save && @next_player_state.save, ["players"] do
			publish_data @next_player_state, ["players"]
		end
  end

  private

  def set_state
    @game_state = GameState.find params[:id]
  end

  def handle_response(no_error, states = ALL_STATES, &block)
		set_state # awkwaaarddd

    if no_error
      publish_data @game_state, states
      block

      render json: @game_state, status: :updated
    else
      render json: @game_state.errors, status: :unprocessable_entity
    end
  end
end
