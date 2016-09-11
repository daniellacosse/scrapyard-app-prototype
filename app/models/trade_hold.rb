class TradeHold < ActiveRecord::Base
  belongs_to :trade, dependent: :destroy
  belongs_to :scrap_hold

  def owner
    scrap_hold.game_state.player
  end

  def name
    scrap_hold.scrap.name
  end
end
