require 'json'

class GamesController < ApplicationController
  before_action :authenticate_player!
  before_action :set_game, only: [:show, :edit, :update, :destroy, :join]

  # GET /games
  def index
    @games = Game.all
  end

  # POST /games/1/join
  def join
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

  # GET /games/new
  def new
    @game = Game.new(guid: (rand * 10_000).ceil)
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to games_path, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /games/1
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:guid)
  end
end
