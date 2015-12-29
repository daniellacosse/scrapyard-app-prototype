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
        @last_active = Time.zone.now

        begin
          r.subscribe sub_string, "heartbeat" do |on|
            puts "#{current_player.email} Connected!"

            on.message do |_event, data|
              current_state = GameState.find params[:id]
              idle_time = (Time.zone.now - current_state.updated_at).to_i
              r.unsubscribe if idle_time > 3.seconds

              response.stream.write "event: update\n"
              response.stream.write "data: #{data}\n\n"
            end
          end
        rescue IOError
          puts "IOError"
        rescue ClientDisconnected
          puts "ClientDisconnected"
        rescue ActionController::Live::ClientDisconnected
          puts "Live::ClientDisconnected"
        ensure
          puts "<<< STREAM IS KILL >>>\n"

          r.quit
          response.stream.close
        end
      end
    end
  end

  # PUT /game_states/:id
  def update
    if params[:is_new_id]
      # TODO
    elsif @game_state.stream_id = params[:steam_id]
      # TODO
    end
  end

  # POST /game_states/:id/draw/:card_type
  def draw
    card_id = params[:card_id]
    card_type = params[:card_type]

    if card_type == "scrap"
      @game_state.scrap_holds << ScrapHold.create(scrap_id: card_id)
      # TODO: check to see if any player needs that & notify them
      handle_response @game_state.save, [ "scraps" ]

    elsif card_type == "blueprint"
      @game_state.blueprint_holds << BlueprintHold.create(blueprint_id: card_id)

      @game_state.siblings.each { |state| publish_data state, ["blueprint", "available_blueprints"] }
      render json: @game_state, status: :updated
    else
      flash[:error] = "Card type drawn (#{card_type}) invalid!"
    end

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
    all_ready = @game_state.set_ready

    @game_state = GameState.find params[:id]

    if all_ready
      @game_state.siblings.each { |state| publish_data state, ALL_STATES }
    else
      @game_state.siblings.each { |state| publish_data state, [ "players" ] }
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

    success = @game_state.update(is_my_turn: false) && @next_player_state.update(is_my_turn: true)

    @game_state = GameState.find params[:id]
    @next_player_state = GameState.find @next_player_state.id

    @game_state.siblings.each { |state| publish_data state, [ "players" ] }
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
