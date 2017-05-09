class GameController < ApplicationController
  
  def board
  end

  def data
    render json: {
      board_data: Board.last.board_data, 
      white_to_move: Board.last.white_to_move,
      moves: Board.last.moves.map { |move| move.to_s },
      castling: Board.last.castling
    }
  end

  def move
    move = params[:move]
    my_move = Move.new([move[0].to_i, move[1].to_i], [move[2].to_i, move[3].to_i])
    board = Board.last
    new_board = board.move(my_move)
    if new_board
      new_board.game = Game.last
      new_board.save
      ActionCable.server.broadcast "game_channel", { board_data: new_board.board_data, white_to_move: new_board.white_to_move }
    end
  end

  def reset
    first_board_data = Board.first.board_data
    Board.destroy_all
    Board.create(
      game_id: 1,
      ply: 1,
      board_data: first_board_data,
      white_to_move: true,
      castling: "1111",
      en_passant: "0000"
    )
  end
end
