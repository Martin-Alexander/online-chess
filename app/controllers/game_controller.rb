class GameController < ApplicationController
  
  def home
  end

  def new_single_player
  end

  def new_multiplayer
  end

  def create_multiplayer
  end

  def join

    @games = Game.all.select { |game| !game.full? && game.white != current_user }

  end

  def create
    if params[:ai]
      new_game = Game.create(
        white: current_user ? current_user : User.find_by(email: "guest"),
        black: User.find_by(email: params[:ai])
      )
    else
      new_game = Game.create(
        white: current_user,
        black: nil
      )      
    end
    Board.create(game: new_game)
    redirect_to show_path(new_game)
  end

  def show
    @game = Game.find(params[:game_id])
    @game_id = @game.id
    @black_player = @game.black
    @white_player = @game.white
    @white_to_move = @game.boards.last.white_to_move
  end

  def data
    board = Game.find(params[:game_id]).boards.last
    render json: {
      board_data: board.board_data, 
      white_to_move: board.white_to_move,
      moves: board.moves.map { |move| move.to_s },
      castling: board.castling
    }
  end

  def move
    move = moveify(params[:move])
    current_game = Game.find(params[:gameId])
    board = current_game.boards.last
    new_board = board.move(move)

    if board.turn_player == current_user || board.turn_player.email == "guest"
      if new_board
        new_board.game = current_game
        new_board.save
        ActionCable.server.broadcast "game_channel", { 
          board_data: new_board.board_data, 
          white_to_move: new_board.white_to_move, 
          game_id: params["gameId"].to_s 
        }
        if new_board.turn_player.human == false
          EngineThought.perform_later(new_board.id, current_game.id, new_board.turn_player.email)
        end
      end
    else
      @not_your_turn = true
    end

  end

  private

  def moveify(string)
    Move.new(
      [string[0].to_i, string[1].to_i], 
      [string[2].to_i, string[3].to_i], 
      promotion: string.length == 5 ? string[4].to_i : 0 
    )
  end
end
