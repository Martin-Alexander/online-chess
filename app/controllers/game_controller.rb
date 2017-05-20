class GameController < ApplicationController
  
  def home
    @all_games = Game.all
  end

  def new
    if !current_user.nil?
      # @all_other_players = User.where.not(email: current_user.email)
      @all_other_players = User.all
    else
      redirect_to home_path
    end
  end

  def create
    white_to_move = params["white_to_move"]
    board_data = params["board_data"]
    player_two = params["player_two"]
    player_one_color = params["player_one_color"]

    game = if player_one_color == "white"
      Game.create(white: current_user, black_id: player_two)
    else
      Game.create(white_id: player_two, black: current_user)
    end
    if board_data.empty? 
      Board.create!(game: game)
    else
      Board.create!(game: game, white_to_move: white_to_move, board_data: board_data)
    end
    redirect_to show_path(game.id)
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
    if (board.white_to_move && board.game.white == current_user) || (!board.white_to_move && board.game.black == current_user)
      if new_board
        new_board.game = current_game
        new_board.save
        ActionCable.server.broadcast "game_channel", { board_data: new_board.board_data, white_to_move: new_board.white_to_move, game_id: params["gameId"].to_s }
        if new_board.turn_player.human == false
          puts "===== ENGINE THOUGHT ====="
          EngineThought.perform_now(new_board.id, current_game.id, new_board.turn_player.email)
        end
      end
    else
      @not_your_turn = true
    end
  end
end
