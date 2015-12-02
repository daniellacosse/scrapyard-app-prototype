require "json"

class GamesController < ApplicationController
  include ActionController::Live
  before_action :authenticate_player!
  before_action :set_game, only: [:show, :edit, :update, :destroy]
  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
     response.headers["Content-Type"] = "text/event-stream"

     r = Redis.new # url: ENV["REDIS_URL"] || "redis://127.0.0.1:6379/0"
     begin
       r.subscribe("game#{@game.id}") do |on|
          on.message do |event, data|
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

  # POST /games/1/join
  def join
     @game = Game.find params["id"]

     if !!GameState.where(player_id: current_player.id, game_id: @game.id).first
        flash[:error] = "You\'re already in this game!"
        redirect_to @game
        return
     end

     if @game.players.count > 4
        flash[:error] = "This game is full!"
        redirect_to games_url
        return
     end

     respond_to do |format|
       @game_state = GameState.new(
         player_id: current_player.id, game_id: @game.id
       )

       if @game_state.save
          publish_game_data @game

          format.html do
             redirect_to game_state_path(@game_state), notice: "Joined Game!"
          end

          format.json { render :show, status: :created, location: @game }
       else
          format.json do
             render json: @game_state.errors, status: :unprocessable_entity
          end
       end
     end
  end

  # GET /games/new
  def new
    @game = Game.new
    @game.guid = (rand * 10000).ceil
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to games_path, notice: "Game was successfully created." }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: "Game was successfully updated." }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: "Game was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      params.require(:game).permit(:guid)
    end

    def publish_game_data(data)
      r = Redis.new # url: ENV["REDIS_URL"] || "redis://127.0.0.1:6379/0"
      r.publish(
         "game#{data.id}",
         JSON.dump(
            players: data.players.collect(&:email),
            available_blueprints: data.available_blueprints
         )
      )
    end
end
