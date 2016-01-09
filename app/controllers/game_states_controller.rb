require "json"

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
		:trade, :build, :sell, :end_turn, :ready,
    :discard_raw
  ]

  before_action :close_db_connection, only: :show

  def show
    respond_to do |format|
      format.html { render :show }

      format.json do
        response.headers['Content-Type'] = 'text/event-stream'

        sub_string = "stream#{@game_state.id}"
        @last_active = Time.zone.now

        begin
          $redis.subscribe sub_string do |on|
            puts "#{current_player.email} Connected!"

            on.message do |_event, data|
              # current_state = GameState.find params[:id]
              # idle_time = (Time.zone.now - current_state.updated_at).to_i

              # if idle_time > 3.seconds
              #   $redis.unsubscribe
              #   $redis.quit
              #   response.stream.close
              # end

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

          $redis.quit
          response.stream.close
        end
      end
    end
  end

  # PUT /game_states/:id
  def update
    connection_string = ("a".."z").to_a.shuffle[0,8].join

    if params[:is_new_id]
      @game_state.stream_id = params[:stream_id]
      @game_state.connection_string = connection_string
    elsif @game_state.stream_id == params[:steam_id] && @game_state.connection_string == params[:connection_string]
      @game_state.connection_string = connection_string
    end

    if @game_state.save
      respond_to do |format|
        format.html { render :show }
        format.json do
          render json: { ok: true, connection_string: connection_string }
        end
      end
    else
      render json: @game_state.errors, status: :unprocessable_entity
    end
  end

  def discard_raw
    success = @game_state.update(raw: @game_state.raw - params[:raw_amount].to_i)

    handle_response success, ["raw"]
  end

  # POST /game_states/:id/draw/:card_type
  def draw
    card_id, card_type = params[:card_id], params[:card_type]

    if card_type == "scrap" && !!card_id && card_id != 0
      hold = ScrapHold.create(scrap_id: card_id)
      @game_state.scrap_holds << hold

      handle_response @game_state.save, [ "scraps" ] do
        scrap = hold.scrap

        @game_state.siblings.each do |sibling|
          next if sibling.id == @game_state.id
          matches = sibling.blueprints.to_a.select do |bp|
            !sibling.holds?(scrap) && bp.requires?(scrap)
          end

          if matches.length > 0
            alert_text = <<-HEREDOC
              #{@game_state.player.email} just drew a(n) #{scrap.name}!
              (You'll need one for: #{matches.map(&:name).join(', ')}.)
            HEREDOC

            send_alert to: sibling, with: alert_text
          end
        end
      end
    elsif card_type == "blueprint" && !!card_id && card_id != 0
      @game_state.blueprint_holds << BlueprintHold.create(blueprint_id: card_id)

      handle_response @game_state.save, [ "blueprints", "available_blueprints" ] do
        @game_state.siblings.each do |sibling|
          next if sibling.id == @game_state.id

          publish_data sibling, [ "available_blueprints" ]
        end
      end
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
    @blueprint_hold = BlueprintHold.find params[:blueprint_id]
    success = false
    tribute = JSON.parse(params[:build_blob]) if params[:build_blob]

    # transaction do
      if !!tribute
        success = @game_state.update(raw: @game_state.raw - tribute["raw"].to_i)
        success &= tribute["scraps"].map do |scrap_name|
          @game_state.scrap_holds
            .to_a
            .find { |sh| sh.scrap.name == scrap_name }
            .destroy
        end.all?
      end

      success &= @blueprint_hold.destroy
      success &= ModuleHold.create(
        scrapper_module_id: @blueprint_hold.blueprint.scrapper_module.id,
        game_state_id: @game_state.id
      )
    # end

    publish_data @game_state, ALL_STATES; render :show
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
      block.call if block

      render json: @game_state, status: :updated
    else
      render json: @game_state.errors, status: :unprocessable_entity
    end
  end

  def close_db_connection
    ActiveRecord::Base.connection_pool.release_connection
  end
end
