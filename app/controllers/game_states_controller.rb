class GameStatesController < ApplicationController
  before_action :authenticate_player!
  before_action :set_state

  def show
    @game_state.messages.each do |message|
      unless message.is_viewed
        flash[:alert] ||= []
        flash[:alert] << message.text

        message.update(is_viewed: true)
      end
    end

    render :show
  end

  # POST /game_states/:id/discard_raw
  def discard_raw
    @game_state.update raw: @game_state.raw - params[:raw_amount].to_i

    redirect_to game_state_path(@game_state)
  end

  # POST /game_states/:id/ready
  def ready
    @game_state.set_ready

    redirect_to game_state_path(@game_state)
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

    redirect_to game_state_path(@game_state)
  end

  def destroy
    @game_state.destroy

    redirect_to games_url
  end

  private
  def set_state
    @game_state = GameState.find params[:id]
  end
end
