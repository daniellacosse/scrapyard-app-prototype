class TradesController < ApplicationController
  before_action :set_trade, only: [:show, :edit, :update, :destroy]

  # GET /game_states/:game_state_id/trades/new
  def new
    @solicited_game_state = GameState.find(params[:game_state_id])
    @trade_game = @solicited_game_state.game
    @solicitor_game_state = current_player.state_for_game @trade_game
    @current_player_state = @solicitor_game_state

    @most_scraps_on_the_table = [
      @solicitor_game_state.scrap_holds.length,
      @solicited_game_state.scrap_holds.length
    ].max

    @trade = Trade.new(
      solicited_player_state_id: @solicited_game_state.id,
      solicitor_player_state_id: @solicitor_game_state.id
    )

    if @solicitor_game_state.raw == 0 && @solicitor_game_state.scrap_holds.count == 0
      flash[:error] = "You don't have anything to trade."

      redirect_to @current_player_state
    elsif @solicited_game_state.raw == 0 && @solicited_game_state.scrap_holds.count == 0
      flash[:error] = "#{@solicited_game_state.player.email} has nothing to trade."

      redirect_to @current_player_state
    else
      render :new
    end
  end

  # GET /trades/:id/edit
  def edit
    @solicitor_game_state = @trade.solicitor_game_state
    @solicited_game_state = @trade.solicited_game_state
    @current_player_state = current_player.state_for_game @trade.game

    @most_scraps_on_the_table = [
      @solicitor_game_state.scrap_holds.length,
      @solicited_game_state.scrap_holds.length
    ].max
  end

  def show
    @most_scraps_on_the_table = [
      @trade.solicitor_trade_holds.length,
      @trade.solicited_trade_holds.length
    ].max

    @current_player_state = current_player.state_for_game @trade.game
  end

  # POST /game_states/:game_state_id/trades
  def create
    @solicited_game_state = GameState.find(params[:game_state_id])
    @trade_game = @solicited_game_state.game
    @solicitor_game_state = current_player.state_for_game @trade_game

    @trade = Trade.new(
      game_id: @trade_game.id,
      solicited_player_state_id: @solicited_game_state.id,
      solicitor_player_state_id: @solicitor_game_state.id,
      solicited_raw_cost: trade_params["solicited_raw_cost"],
      solicitor_raw_cost: trade_params["solicitor_raw_cost"],
      is_agreed: false
    )

    scrap_hold_ids = trade_params["trade_holds"]
      .select { |scrap_hold_id| scrap_hold_id != "0" }
      .map(&:to_i);

    respond_to do |format|
      if @trade.save_with_holds(scrap_hold_ids)
        Message.create(text: "#{@trade.solicitor_player.email} would like to trade with you! Check the trade proposals section at the bottom of the page.", game_state_id: @trade.solicited_game_state.id)

        format.html { redirect_to game_state_path(@solicitor_game_state) }
        format.json { render :show, status: :created, location: @trade }
      else
        format.html { render :new }
        format.json { render json: @trade.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trades/:id
  def update
    @current_player_state = current_player.state_for_game @trade.game

    respond_to do |format|
      trade_success = true

      if trade_params == "is_agreed=true"
        trade_success &= @trade.update({ is_agreed: true })

        trade_success &= @trade.make

        trade_success &= Message.create(text: "#{@trade.solicited_player.email} accepted your trade request!", game_state_id: @trade.solicitor_game_state.id)
      elsif trade_params == "is_revised=true"
        scrap_hold_ids = trade_params["trade_holds"]
          .select { |scrap_hold_id| scrap_hold_id != "0" }
          .map(&:to_i)

        trade_success &= @trade.reset_trade_holds(scrap_hold_ids)

        trade_success &= Message.create(text: "#{@trade.solicited_player.email} modified your trade request.", game_state_id: @trade.solicitor_game_state.id)

        trade_success &= @trade.update({ is_revised: true })
      else
        scrap_hold_ids = trade_params["trade_holds"]
          .select { |scrap_hold_id| scrap_hold_id != "0" }
          .map(&:to_i)

        trade_success &= @trade.reset_trade_holds(scrap_hold_ids)

        trade_success &= Message.create(text: "#{@trade.solicited_player.email} modified your trade request.", game_state_id: @trade.solicitor_game_state.id)

        trade_success &= @trade.update({ is_revised: false })
      end

      if trade_success
        format.html { redirect_to game_state_path(@current_player_state) }
      else
        format.html { render :edit }
        format.json { render json: @trade.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trades/:id
  def destroy
    @current_player_state = current_player.state_for_game @trade.game

    @trade.destroy
    respond_to do |format|
      format.html { redirect_to game_state_path(@current_player_state) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trade
      @trade = Trade.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trade_params
      params[:trade]
    end
end
