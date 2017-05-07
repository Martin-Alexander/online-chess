class GameController < ApplicationController

  def board
  end

  def game
    @legal_moves = Board.last.moves.map { |move| move.to_s}
    @board_data = Board.last.board_data
  end

  def move
    move = params[:move]
    my_move = Move.new([move[0].to_i, move[1].to_i], [move[2].to_i, move[3].to_i])
    board = Board.last
    new_board = board.move(my_move)
    if new_board
      new_board.game = Game.last
      new_board.save
      ActionCable.server.broadcast "game_channel", { board_data: new_board.board_data }
    end
  end
  
  def new
    render :json => { data: Board.last.board_data }
  end

end
