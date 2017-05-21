class EngineThought < ApplicationJob

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
		send(name.to_sym, initial_board, current_game)
  end

	PAWN_POS_EVAL = [
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8],
		[0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6, 0.6],
		[0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4],
		[0.1, 0.1, 0.2, 0.5, 0.5, 0.2, 0.1, 0.1],
		[0.1, 0.1, 0.2, 0.2, 0.2, 0.2, 0.1, 0.1],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0]
	]

	KNIGHT_POS_EVAL = [
		[-0.4, -0.4, -0.4, -0.4, -0.4, -0.4, -0.4, -0.4],
		[-0.4, 0, 0, 0, 0, 0, 0, -0.4],
		[-0.4, 0, 0, 0, 0, 0, 0, -0.4],
		[-0.4, 0, 0, 0, 0, 0, 0, -0.4],
		[-0.4, 0, 0, 0, 0, 0, 0, -0.4],
		[-0.4, 0, 0, 0, 0, 0, 0, -0.4],
		[-0.4, 0, 0, 0, 0, 0, 0, -0.4],
		[-0.4, -0.4, -0.4, -0.4, -0.4, -0.4, -0.4, -0.4]
	]

	BISHOP_POS_EVAL = [
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0.2, 0, 0, 0, 0, 0.2, 0],
		[0, 0, 0.2, 0, 0, 0.2, 0, 0],
		[0, 0, 0, 0.2, 0.2, 0, 0, 0],
		[0, 0, 0, 0.2, 0.2, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0]
	]

	ROOK_POS_EVAL = [
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]
	]

	QUEEN_POS_EVAL = [
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0]
	]

	KING_POS_EVAL = [
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0],
		[-0.4, -0.4, -0.4, -0.4, -0.4, -0.4, -0.4, -0.4],
		[-0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2, -0.2],
		[0.2, 0.2, 10, 0.2, 0.2, 0.2, 10, 0.2]
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

	# ============ CHESS ENGINES ============

  def babyburger(initial_board, current_game)
	  computer_move_board = initial_board.move(initial_board.moves.sample)
    computer_move_board.game = current_game
    computer_move_board.save!
    ActionCable.server.broadcast "game_channel", { board_data: computer_move_board.board_data, white_to_move: computer_move_board.white_to_move, game_id: current_game.id.to_s }
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
  	ActionCable.server.broadcast "game_channel", { board_data: computer_move_board.board_data, white_to_move: computer_move_board.white_to_move, game_id: current_game.id.to_s }
  end

  # ============ HELPER METHODS ============

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