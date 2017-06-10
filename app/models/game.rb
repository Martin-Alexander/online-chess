class Game < ApplicationRecord
  belongs_to :black, class_name: "User", optional: true
  belongs_to :white, class_name: "User", optional: true
  has_many :boards, dependent: :destroy
  after_create :first_board_create

  def current_board
    self.boards.last
  end

  def game_over?
    self.current_board
  end

  def first_board_create
    Board.create(game: self)
  end
end
