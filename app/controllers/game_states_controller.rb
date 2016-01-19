class GameStatesController < ApplicationController
  before_action :authenticate_player!
  before_action :set_state, only: [:show, :update, :destroy]

  # GET /game_states/:id
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

  # POST /games/:game_id/game_states
  def create
    @game = Game.find(params[:game_id])

    if @game.players.count > 4
      flash[:error] = "This game is full!"
      redirect_to games_url
    elsif @game.has_started
      flash[:error] = "This game is already underway!"
      redirect_to games_url
    else
      @game_state = GameState.find_or_create_by(
        player_id: current_player.id, game_id: @game.id
      )

      redirect_to game_state_path(@game_state), notice: "Joined Game!"
    end
  end

  # PUT/PATCH /game_states/:id
  def update
    if params[:is_ready]
      @game_state.set_ready
    elsif params[:is_my_turn] == false
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
    end

    redirect_to game_state_path(@game_state)
  end

  # DELETE /game_states/:id
  def destroy
    @game_state.destroy

    redirect_to games_url
  end

  private
  def set_state
    @game_state = GameState.find params[:id]
  end
end
