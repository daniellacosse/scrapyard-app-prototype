class ScrapHold < ActiveRecord::Base
	belongs_to :game_state
	belongs_to :scrap
end
