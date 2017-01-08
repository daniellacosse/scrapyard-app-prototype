class Contestant < ActiveRecord::Base
  has_many :game_states
end
