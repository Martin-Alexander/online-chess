class EngineThought < ApplicationJob
  require 'socket'
  queue_as :default

  Fixnum.send(:include, ChessPiece)
  Array.send(:include, SerializeBoard)
  String.send(:include, ParseBoard)

  def each_square
    (0..7).each do |rank|
      (0..7).each do |file|
        yield(rank, file)
      end
    end
  end

  def perform(board_id, game_id, name)
    current_game = Game.find(game_id)
    initial_board = Board.find(board_id)
    # send(name.to_sym, initial_board, current_game)
    if ["babyburger", "teenburger"].include?(name)
      send(name.to_sym, initial_board, current_game)
    else
      engine_thought(initial_board, current_game, name)
    end
  end

  PAWN_POS_EVAL = [
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.8,  0.8,  0.8,  0.8,  0.8,  0.8,  0.8,  0.8],
    [ 0.6,  0.6,  0.6,  0.6,  0.6,  0.6,  0.6,  0.6],
    [ 0.2,  0.2,  0.2,  0.4,  0.4,  0.2,  0.2,  0.2],
    [ 0.1,  0.1,  0.1,  0.5,  0.5,  0.1,  0.1,  0.1],
    [ 0.0,  0.0,  0.0,  0.3,  0.3,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0, -0.2, -0.2,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0]
  ]

  KNIGHT_POS_EVAL = [
    [-0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2],
    [-0.2,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -0.2],
    [-0.2,  0.0,  0.1,  0.1,  0.1,  0.1,  0.0, -0.2],
    [-0.2,  0.0,  0.1,  0.1,  0.1,  0.1,  0.0, -0.2],
    [-0.2,  0.0,  0.1,  0.1,  0.1,  0.1,  0.0, -0.2],
    [-0.2,  0.0,  0.2,  0.1,  0.1,  0.2,  0.0, -0.2],
    [-0.2,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -0.2],
    [-0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2]
  ]

  BISHOP_POS_EVAL = [
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0, -0.1,  0.0,  0.0, -0.1,  0.0,  0.0]
  ]

  ROOK_POS_EVAL = [
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.2,  0.2,  0.2,  0.2,  0.2,  0.2,  0.2,  0.2],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.2,  0.2,  0.2,  0.2,  0.2,  0.2,  0.2,  0.2]
  ]

  QUEEN_POS_EVAL = [
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0]
  ]

  KING_POS_EVAL = [
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [ 0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
    [-0.4, -0.4, -0.4, -0.4, -0.4, -0.4, -0.4, -0.4],
    [-0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2],
    [ 0.2,  0.2,  0.3,  0.2,  0.2,  0.2,  0.3,  0.2]
  ]

  PIECE_VALUE = {
    "pawn" => 1,
    "knight" => 3, 
    "bishop" => 3,
    "rook" => 5,
    "queen" => 8,
    "king" => 1
  }

  POS_EVAL_LOOKUP = {
    "pawn" => PAWN_POS_EVAL,
    "knight" => KNIGHT_POS_EVAL, 
    "bishop" => BISHOP_POS_EVAL,
    "rook" => ROOK_POS_EVAL,
    "queen" => QUEEN_POS_EVAL,
    "king" => KING_POS_EVAL
  }

  ENGINE_LOOKUP = {
    mamaburger: :mama_thought,
    papaburger: :papa_thought,
    grandpaburger: :grandpa_thought
  }

  # ============ CHESS ENGINES ============

  def babyburger(initial_board, current_game)
  computer_move_board = initial_board.move(initial_board.moves.sample)
    computer_move_board.game = current_game
    computer_move_board.save!
    send_back_board(computer_move_board, current_game)
  end

  def teenburger(initial_board, current_game)
    legal_moves = initial_board.moves
    legal_moves_indexes = (0...legal_moves.length).map { |i| i }
    move_evaluations = legal_moves.map { |legal_move| static_board_evaluation(initial_board.move(legal_move).board_data.to_board) }
    computer_move_board = initial_board.move(
      initial_board.white_to_move ? legal_moves[move_evaluations.zip(legal_moves_indexes).max[1]] : legal_moves[move_evaluations.zip(legal_moves_indexes).min[1]]
    )
    computer_move_board.game = current_game
    computer_move_board.save!
    sleep(0.5)
    send_back_board(computer_move_board, current_game)
  end

  def engine_thought(initial_board, current_game, name)
    if initial_board.moves.empty?
      puts "Game over"
      if initial_board.check_mate?
        puts "Checkmate"
      else
        puts "Stalemate"
      end
    else
      move_evaluations = send(ENGINE_LOOKUP[name.to_sym], (initial_board))
      best_move_index = move_evaluations.each_with_index.max[1]
      computer_move_board = initial_board.move(initial_board.moves[best_move_index])
      computer_move_board.game = current_game
      computer_move_board.save!
      puts "Board evaluation: #{move_evaluations.max.round(2)} #{move_evaluations.max > 0 ? ':)' : ':('}"
      send_back_board(computer_move_board, current_game)
    end
  end

  # ============ HELPER METHODS ============

  def send_back_board(board, game)
    ActionCable.server.broadcast "game_channel", {
      board_data: board.board_data,
      white_to_move: board.white_to_move,
      game_id: game.id,
      board_id: board.id
    }
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

  def papa_thought(board_object)

    parent, child = UNIXSocket.pair
    board_object.moves.each_with_index do |move_one, i|
      fork_with_new_connection do
        branch_one = []
        first_level_board = board_object.computer_move(move_one)
        first_level_board_moves = first_level_board.moves
        if first_level_board_moves.empty? && first_level_board.check_mate?
          child.send "999Q #{i},", 0
        elsif first_level_board_moves.empty? 
          child.send "0Q #{i},", 0
        else
          first_level_board_moves.each do |move_two|
            branch_two = []
            second_level_board = first_level_board.computer_move(move_two)
            second_level_board_moves = second_level_board.moves
            if second_level_board_moves.empty? && second_level_board.check_mate?
              branch_one << [[[-999]]]
            elsif second_level_board_moves.empty?
              branch_one << [[[0]]]          
            else
              branch_one << branch_two
              second_level_board_moves.each do |move_three|
                branch_three = []
                third_level_board = second_level_board.computer_move(move_three)
                if move_three.capture || third_level_board.check?
                # if move_three.capture
                  third_level_board_moves = third_level_board.moves
                  if third_level_board_moves.empty? && third_level_board.check_mate?
                    branch_two << [[999]]
                  elsif third_level_board_moves.empty?
                    branch_two << [[0]]
                  else
                    branch_two << branch_three
                    third_level_board_moves.each do |move_four|
                      branch_four = []
                      fourth_level_board = third_level_board.computer_move(move_four)
                      # if move_four.capture || fourth_level_board.check?
                      # if move_four.capture
                      #   fourth_level_board_moves = fourth_level_board.moves
                      #   if fourth_level_board_moves.empty? && fourth_level_board.check_mate?
                      #     branch_thee << [-999]
                      #   elsif fourth_level_board_moves.empty?
                      #     branch_three << [0]
                      #   else
                      #     branch_three << branch_four
                      #     fourth_level_board_moves.each do |move_five|
                      #       fifth_level_board = fourth_level_board.move(move_five)
                      #       board_eval = static_board_evaluation(fifth_level_board.board_data.to_board)
                      #       board_object.white_to_move ? branch_four <<  board_eval : branch_four << 0 - board_eval                            
                      #     end
                      #   end
                      # else
                        board_eval = static_board_evaluation(fourth_level_board.board_data.to_board)
                        board_object.white_to_move ? branch_three <<  board_eval : branch_three << 0 - board_eval
                      # end
                    end
                  end
                else
                  board_eval = static_board_evaluation(third_level_board.board_data.to_board)
                  board_object.white_to_move ? branch_two <<  board_eval : branch_two << 0 - board_eval                  
                end
              end
            end
          end
          child.send "#{tree_evaluator_helper(branch_one, 0).min}Q #{i},", 0
        end
      end
    end

    Process.waitall

    end_time = Time.now
    move_tree_parser parent.recv(10000)
  end

  def grandpa_thought(board_object)
    
    parent, child = UNIXSocket.pair
    board_object.moves.each_with_index do |move_one, i|
      fork_with_new_connection do
        branch_one = []
        first_level_board = board_object.computer_move(move_one)
        first_level_board_moves = first_level_board.moves
        if first_level_board_moves.empty?
          child.send "999Q #{i},", 0
        else
          first_level_board_moves.each do |move_two|
            branch_two = []
            second_level_board = first_level_board.computer_move(move_two)
            second_level_board_moves = second_level_board.moves
            if second_level_board_moves.empty?
              branch_one << [[-999]]
            else
              branch_one << branch_two
              second_level_board_moves.each do |move_three|
                branch_three = []
                third_level_board = second_level_board.computer_move(move_three)
                third_level_board_moves = third_level_board.moves
                if third_level_board_moves.empty?
                  branch_two << [999]
                else
                  branch_two << branch_three
                  third_level_board_moves.each do |move_four|
                    fourth_level_board = third_level_board.computer_move(move_four)
                    board_eval = static_board_evaluation(fourth_level_board.board_data.to_board)
                    board_object.white_to_move ? branch_three <<  board_eval : branch_three << 0 - board_eval
                  end
                end
              end
            end
          end
          child.send "#{tree_evaluator_helper(branch_one, 0).min}Q #{i},", 0
        end
      end
    end

    Process.waitall

    end_time = Time.now
    move_tree_parser parent.recv(10000)
  end


  def mama_thought(board_object)
    parent, child = UNIXSocket.pair
    board_object.moves.each_with_index do |move_one, i|
      fork_with_new_connection do
        branch_one = []
        first_level_board = board_object.computer_move(move_one)
        first_level_board_moves = first_level_board.moves
        if first_level_board_moves.empty?
          child.send "999Q #{i},", 0
        else
          first_level_board_moves.each do |move_two|
            branch_two = []
            second_level_board = first_level_board.computer_move(move_two)
            second_level_board_moves = second_level_board.moves
            if second_level_board_moves.empty?
              branch_one << [-999]
            else
              branch_one << branch_two
              second_level_board_moves.each do |move_three|
                third_level_board = second_level_board.computer_move(move_three)
                board_eval = static_board_evaluation(third_level_board.board_data.to_board)
                board_object.white_to_move ? branch_two <<  board_eval : branch_two << 0 - board_eval
              end
            end
          end
          child.send "#{tree_evaluator_helper(branch_one, 0).min}Q #{i},", 0
        end
      end
    end
    Process.waitall
    end_time = Time.now
    move_tree_parser parent.recv(10000)
  end

  # def deep_thought(board, board_moves, depth, branch)
  #   if depth == 1
  #     board_moves.each_with_index do |move, i|
  #       new_branch = []
  #       new_board = board.computer_move(move)
  #       new_board_moves = new_board.moves
  #       if board_moves.empty?
  #         child.send "999Q #{i},", 0
  #       else
  #         deep_thought(new_board, new_board_moves, depth - 1, new_branch)
  #       end
  #     end
  #   elsif depth < 2

  #   else
  #   end      
  # end    

  def move_tree_parser(move_tree)
    move_tree = move_tree.split(",").each { |i| i.to_i }
    move_tree.map! { |i| i.split("Q") }
    move_tree.map! { |i| [i[0], i[1].to_i] }
    move_tree.sort_by! { |i| i[1] }
    move_tree.map! { |i| i[0].to_f }
    move_tree
  end

  def tree_evaluator_helper(list, level)
    if list.any? { |i| i.kind_of?(Array) }
      if level % 2 == 0
        return(list.map { |j| j.is_a?(Array) ? (tree_evaluator_helper(j, level + 1)).max : j })
      else
        return(list.map { |j| j.is_a?(Array) ? (tree_evaluator_helper(j, level + 1)).min : j })
      end
    else
      return(list)  
    end
  end

  def tree_evaluator(list)
    tree_evaluator_helper(list, 1)
  end

  def fork_with_new_connection
    # Store the ActiveRecord connection information
    config = ActiveRecord::Base.remove_connection

    pid = fork do
      # tracking if the op failed for the Process exit
      success = true

      begin
        ActiveRecord::Base.establish_connection(config)
        
        # This is needed to re-initialize the random number generator after forking (if you want diff random numbers generated in the forks)
        srand

        # Run the closure passed to the fork_with_new_connection method
        yield

      rescue Exception => exception
        puts ("Forked operation failed with exception: " + exception)
        
        # the op failed, so note it for the Process exit
        success = false

      ensure
        ActiveRecord::Base.remove_connection
        Process.exit! success
      end
    end

    # Restore the ActiveRecord connection information
    ActiveRecord::Base.establish_connection(config)

    #return the process id
    pid
  end
end