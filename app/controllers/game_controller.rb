class GameController < ApplicationController
  
  def home
    @all_games = Game.all
  end

  def new_single_player
  end

  def new_multiplayer
    @list_of_users = User.where(human: true).where.not(email: "guest")
  end

  def create
    if params[:ai]
      new_game = Game.create(white: current_user ? current_user : User.where(email: "guest").first, black: User.where(email: params[:ai]).first)
      Board.create(game: new_game)
      redirect_to show_path(new_game)
    end
  end

  def show
    game = Game.find(params[:game_id])
    @game_id = game.id
    @black_player = game.black
    @white_player = game.white
    @white_to_move = game.boards.last.white_to_move
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
    move = params[:move]
    my_move = Move.new([move[0].to_i, move[1].to_i], [move[2].to_i, move[3].to_i], promotion: move.length == 5 ? move[4].to_i : 0 )
    current_game = Game.find(params[:gameId])
    board = current_game.boards.last
    new_board = board.move(my_move)
    if board.turn_player == current_user || board.turn_player.email == "guest"
      if new_board
        new_board.game = current_game
        new_board.save
        ActionCable.server.broadcast "game_channel", { board_data: new_board.board_data, white_to_move: new_board.white_to_move, game_id: params["gameId"].to_s }
        if new_board.turn_player.human == false
          puts "===== ENGINE THOUGHT ====="
          EngineThought.perform_later(new_board.id, current_game.id, new_board.turn_player.email)
        end
      end
    else
      @not_your_turn = true
    end
  end
end
