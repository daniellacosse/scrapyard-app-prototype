class Player < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :game_states, dependent: :destroy
  has_many :games, through: :game_states

  def state_for_game(game)
    game_states.to_a.find { |state| state.game_id == game.id }
  end
end
