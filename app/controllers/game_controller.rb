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
        if new_board.turn_player.human == false && !new_board.turn_player.email == "mamaburger"
          puts "===== ENGINE THOUGHT ====="
          EngineThought.perform_now(new_board.id, current_game.id, new_board.turn_player.email)
        elsif new_board.turn_player.email == "mamaburger"
          move_list = deep_thought(new_board)
          p move_list
          p tree_evaluator(move_list)
        end
      end
    else
      @not_your_turn = true
    end
  end

  def deep_thought(board_object)
    tree = []
    board_object.moves.each do |move_one|
      branch_one = []
      tree << branch_one
      first_level_board = board_object.move(move_one)
      first_level_board.moves.each do |move_two|
        branch_two = []
        branch_one << branch_two
        second_level_board = first_level_board.move(move_two)
        second_level_board.moves.each do |move_three|
          third_level_board = second_level_board.move(move_three)
          branch_two << static_board_evaluation(third_level_board.board_data)
        end
      end
    end
    return tree
  end

  def tree_evaluator_helper(list, level)
    if list.all? { |i| i.kind_of?(Array) }
      if level % 2 == 0
        return(list.map { |j| (tree_evaluator_helper(j, level + 1)).max })
      else
        return(list.map { |j| (tree_evaluator_helper(j, level + 1)).min })
      end
    else
      return(list)  
    end
  end

  def tree_evaluator(list)
    tree_evaluator_helper(list, 1)
  end

  def static_board_evaluation(board_data)
    total_material_score = 0
    each_square do |rank, file|
      square = board_data[rank][file]
      if square.color == "white"
        material_score = PIECE_VALUE[square.piece] + POS_EVAL_LOOKUP[square.piece][rank][file]
        total_material_score += material_score
      elsif square.color == "black"
        material_score = PIECE_VALUE[square.piece] + POS_EVAL_LOOKUP[square.piece].reverse[rank][file]
        total_material_score -= material_score
      end
    end
    return total_material_score
  end

end
