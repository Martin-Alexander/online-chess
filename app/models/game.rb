class Game < ApplicationRecord
  belongs_to :black, class_name: "User"
  belongs_to :white, class_name: "User"
  has_many :boards, dependent: :destroy

  def unfull?
  	white.nil? || black.nil?
  end

  def game_over?
		self.boards.last.moves.zero?  	
  end
end
