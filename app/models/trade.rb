class Trade < ActiveRecord::Base
  belongs_to :game

  has_many :trade_holds

  def make
    transaction do
      trade_holds.each do |trading_scrap|
        scrap_hold = trading_scrap.scrap_hold

        if trading_scrap.scrap_hold.game_state == solicitor_game_state
          scrap_hold.update(game_state_id: solicited_game_state.id)
        else trading_scrap.scrap_hold == solicited_game_state
          scrap_hold.update(game_state_id: solicitor_game_state.id)
        end
      end

      solicitor_game_state.update(raw: solicitor_game_state.raw - solicitor_raw_cost.to_i + solicited_raw_cost.to_i)

      solicited_game_state.update(raw: solicited_game_state.raw - solicited_raw_cost.to_i + solicitor_raw_cost.to_i)
    end
  end

  def save_with_holds(scrap_hold_ids)
    trade_success = true

    transaction do
      trade_success &= save

      scrap_hold_ids.each do |hold_id|
        trade_hold = TradeHold.new({
          trade_id: id,
          scrap_hold_id: hold_id
        })

        trade_success &= trade_hold.save
      end
    end

    trade_success
  end

  def reset_with_holds(scrap_hold_ids)
    trade_success = true

    transaction do
      trade_success &= @trade.trade_holds.destroy_all
      trade_success &= @trade.save_with_holds(scrap_hold_ids)
    end

    trade_success
  end

  def solicitor_player
    solicitor_game_state.player
  end

  def solicitor_game_state
    GameState.find(solicitor_player_state_id)
  end

  def solicitor_scraps
    solicitor_game_state.scrap_holds.select { |hold| hold.player == solicitor_player }
  end

  def solicitor_trade_holds
    trade_holds.select { |hold| hold.scrap_hold.player == solicitor_player }
  end

  def solicited_player
    solicited_game_state.player
  end

  def solicited_game_state
    GameState.find(solicited_player_state_id)
  end

  def solicited_scraps
    solicited_game_state.scrap_holds.select { |hold| hold.player == solicited_player }
  end

  def solicited_trade_holds
    trade_holds.select { |hold| hold.scrap_hold.player == solicited_player }
  end

  def other_player(player)
    player == solicited_player ? solicitor_player : solicited_player
  end

  def this_player_raw_cost(player)
    player == solicited_player ? solicited_raw_cost : solicitor_raw_cost
  end

  def other_player_raw_cost(player)
    player == solicited_player ? solicitor_raw_cost : solicited_raw_cost
  end

  def this_player_scraps(player)
    player == solicited_player ? solicited_scraps : solicitor_scraps
  end

  def other_player_scraps(player)
    player == solicited_player ? solicitor_scraps : solicited_scraps
  end

  def this_player_trade_holds(player)
    player == solicited_player ? solicited_trade_holds : solicitor_trade_holds
  end

  def other_player_trade_holds(player)
    player == solicited_player ? solicitor_trade_holds : solicited_trade_holds
  end
end
