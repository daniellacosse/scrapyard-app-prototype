class TradesController < ApplicationController
  before_action :set_trade, only: [:show, :edit, :update, :destroy]

  # GET /game_states/:game_state_id/trades/new
  def new
    @trade = Trade.new
    @game_state = GameState.find(params[:game_state_id])

    @proposer_state = current_player.state_for_game @game_state.game

    if @proposer_state.raw == 0 && @proposer_state.scrap_holds.count == 0
      flash[:error] = "You don't have anything to trade."

      redirect_to @proposer_state
    elsif @game_state.raw == 0 && @game_state.scrap_holds.count == 0
      flash[:error] = "#{@game_state.player.email} has nothing to trade."

      redirect_to @proposer_state
    else
      render :new
    end
  end

  # GET /trades/:id/edit
  def edit
    @proposer_state = @trade.proposing_state
  end

  def show
  end

  # POST /game_states/:game_state_id/trades
  def create
    @game_state = GameState.find(params[:game_state_id])
    @proposer_state = current_player.state_for_game @game_state.game

    parsed_params = Hash[trade_params.map {|k,v| [k, v.to_i]}]
    parsed_params[:proposing_player_state_id] =  @proposer_state.id

    @trade = @game_state.trades.create(parsed_params)

    respond_to do |format|
      if @trade.save
        format.html { redirect_to game_state_path(@proposer_state) }
        format.json { render :show, status: :created, location: @trade }
      else
        format.html { render :new }
        format.json { render json: @trade.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trades/:id
  def update
    @game_state = @trade.game_state

    unless trade_params == "is_agreed=true"
      swapped_params = {}

      swapped_params[:game_state_id] = trade_params[:proposing_player_state_id]
      swapped_params[:proposing_player_state_id] = trade_params[:game_state_id]
      swapped_params[:raw_cost] = trade_params[:proposing_player_raw_cost]
      swapped_params[:proposing_player_raw_cost] = trade_params[:raw_cost]
      swapped_params[:scrap_hold_cost] = trade_params[:proposing_player_scrap_hold_cost]
      swapped_params[:proposing_player_scrap_hold_cost] = trade_params[:scrap_hold_cost]
      swapped_params[:blueprint_hold_cost] = trade_params[:proposing_player_blueprint_hold_cost]
      swapped_params[:proposing_player_blueprint_hold_cost] = trade_params[:blueprint_hold_cost]
      swapped_params[:module_hold_cost] = trade_params[:proposing_player_module_hold_cost]
      swapped_params[:proposing_player_module_hold_cost] = trade_params[:module_hold_cost]
    end

    respond_to do |format|
      if @trade.update(swapped_params || {is_agreed: true})
        if trade_params == "is_agreed=true"
          @trade.make
          @trade.destroy
        end

        format.html { redirect_to game_state_path(@trade.game_state) }
        format.json { render :show, status: :ok, location: @trade }
      else
        format.html { render :edit }
        format.json { render json: @trade.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trades/:id
  def destroy
    @trade.destroy
    respond_to do |format|
      format.html { redirect_to game_state_path(@game_state) }
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
