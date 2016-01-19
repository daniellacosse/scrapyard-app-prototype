require 'json'

class GamesController < ApplicationController
  before_action :authenticate_player!
  before_action :set_game, only: [:show, :edit, :update, :destroy, :join]

  # GET /games
  def index
    @games = Game.all
  end

  # POST /games/:id/join
  def join
  end

  # GET /games/new
  def new
    @game = Game.new(guid: (rand * 10_000).ceil)
  end

  # GET /games/:id/edit
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

  # PUT /games/:id
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

  # DELETE /games/:id
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
