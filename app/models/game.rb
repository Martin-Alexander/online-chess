class Game < ApplicationRecord
  belongs_to :black, class_name: "User", optional: true
  belongs_to :white, class_name: "User", optional: true
  has_many :boards, dependent: :destroy
  after_create :first_board

  def game_over?
		self.boards.last.moves.zero?  	
  end

  def first_board
  	Board.create(game: self)
  end
end
