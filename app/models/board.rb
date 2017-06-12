class Board < ApplicationRecord
  belongs_to :game

  def move(move)
    if move.is_a? String
      move = Move.new([move[0].to_i, move[1].to_i], [move[2].to_i, move[3].to_i], promotion: move[4].to_i)
    end
    legal = moves.any? do |legal_move|
      legal_move.start_square == move.start_square &&
      legal_move.end_square == move.end_square
    end
    if legal
      new_board_data = execute_move(board_data.to_board, move).serialize_board
      new_board = Board.new(ply: ply + 1, board_data: new_board_data, white_to_move: !white_to_move, castling: castling_update(move), en_passant: en_passant)
    end
    return new_board
  end

  def computer_move(move)
    new_board_data = execute_move(board_data.to_board, move).serialize_board
    Board.new(ply: ply + 1, board_data: new_board_data, white_to_move: !white_to_move, castling: castling_update(move), en_passant: en_passant)
  end

  def moves
    output = []
    each_square do |rank, file|
      if right_color?(rank, file) 
        naive_moves = naive_moves(rank, file, board_data.to_board)
        if !naive_moves.nil?
          naive_moves.each do |naive_move|
            if king_safe?(execute_move(board_data.to_board, naive_move))
              output << naive_move
            end
          end
        end
      end
    end
    return output
  end

  def turn_player
    white_to_move ? self.game.white : self.game.black
  end

  def board_visualization
    board_data.to_board.each do |row|
      row.each { |square| print square < 0 ? "#{square} " : " #{square} " }
      puts
    end
  end

  def check_mate?
    check? && moves.empty?
  end

  def check?
    !king_safe?(board_data.to_board)
  end

  private

  def castling_update(move)
    new_castling = castling
    if move.start_square == [7, 4]
      new_castling[0] = "0"
      new_castling[1] = "0"
    elsif move.start_square == [0, 4]
      new_castling[2] = "0"
      new_castling[3] = "0"
    elsif move.start_square == [7, 7] || move.end_square == [7, 7]
      new_castling[0] = "0"
    elsif move.start_square == [7, 0] || move.end_square == [7, 0]
      new_castling[1] = "0"
    elsif move.start_square == [0, 7] || move.end_square == [0, 7]
      new_castling[2] = "0"
    elsif move.start_square == [0, 0] || move.end_square == [0, 0]
      new_castling[3] = "0"
    end
    return new_castling
  end

  def execute_move(board, move)
    board_copy = board.map { |i| i.dup }
    if board_copy[move.start_square[0]][move.start_square[1]].color == "white"
      promoted_piece = move.promotion
    else 
      promoted_piece = move.promotion * -1
    end
    piece_on_arrival = move.promotion.zero? ? board_copy[move.start_square[0]][move.start_square[1]] : promoted_piece
    board_copy[move.end_square[0]][move.end_square[1]] = piece_on_arrival
    board_copy[move.start_square[0]][move.start_square[1]] = 0
    if move.start_square == [7, 4] && move.end_square == [7, 6] && board[move.start_square[0]][move.start_square[1]].piece == "king"
        board_copy[7][7] = 0
        board_copy[7][5] = 4
    elsif move.start_square == [7, 4] && move.end_square == [7, 2] && board[move.start_square[0]][move.start_square[1]].piece == "king"
        board_copy[7][0] = 0
        board_copy[7][3] = 4
    elsif move.start_square == [0, 4] && move.end_square == [0, 6] && board[move.start_square[0]][move.start_square[1]].piece == "king"
        board_copy[0][7] = 0
        board_copy[0][5] = -4
    elsif move.start_square == [0, 4] && move.end_square == [0, 2] && board[move.start_square[0]][move.start_square[1]].piece == "king"
        board_copy[0][0] = 0
        board_copy[0][3] = -4
    end
    return board_copy
  end

  def naive_moves(rank, file, board)
    case board[rank][file].abs
      when 1 then naive_pawn_moves(rank, file, board)
      when 2 then naive_knight_moves(rank, file, board)
      when 3 then naive_bishop_moves(rank, file, board)
      when 4 then naive_rook_moves(rank, file, board)
      when 5 then naive_queen_moves(rank, file, board)
      when 6 then naive_king_moves(rank, file, board)
    end
  end

  def find_king(test_board)
    right_color = white_to_move ? "white" : "black"
    output = nil
    each_square do |rank, file|
      if !test_board[rank][file].zero? &&
        test_board[rank][file].piece == "king" &&
        test_board[rank][file].color == right_color
        output = [rank, file]
        break
      end
    end
    return output
  end

  def right_color?(rank, file)
    right_color = white_to_move ? "white" : "black"
    board_data.to_board[rank][file].color == right_color
  end

  def king_safe?(board)
    right_color = white_to_move ? "black" : "white"
    king_location = find_king(board)
    safety = true
    catch :king_safety do
      if local_threats_to_king?(board, king_location[0], king_location[1])
        safety = false
        throw :king_safety
      end

      rank = king_location[0]
      file = king_location[1]

      variables = [
        [-1, 0, rank, "rook"],
        [1, 0, 7 - rank, "rook"],
        [0, -1, file, "rook"], 
        [0, 1, 7 - file, "rook"], 
        [-1, 1, [rank, 7 - file].min, "bishop"], 
        [-1, -1, [rank, file].min, "bishop"], 
        [1, -1, [7 - rank, file].min, "bishop"], 
        [1, 1, [7 - rank, 7 - file].min, "bishop"]
      ]

      variables.each do |var|
        unless king_safety_scan?(var[0], var[1], var[2], rank, file, board, var[3])
          safety = false
          throw :king_safety
        end
      end

    end
    return safety
  end

  def local_threats_to_king?(test_board, rank, file)
    threat = false
    catch :king_safety do
      if white_to_move
        king_color = "white"
        pawns = [[rank - 1, file - 1], [rank - 1, file + 1]]
      else
        king_color = "black"
        pawns = [[rank + 1, file - 1], [rank + 1, file + 1]]
      end

      pawns.each do |i|
        if test_board[i[0]] && test_board[i[0]][i[1]] &&
          test_board[i[0]][i[1]].piece == "pawn" &&
          test_board[i[0]][i[1]].color != king_color
          threat = true
          throw :king_safety
        end
      end

      kings = [
        [rank + 1, file + 1], [rank + 1, file], [rank + 1, file - 1], [rank, file + 1],
        [rank, file - 1], [rank - 1, file + 1], [rank - 1, file], [rank - 1, file - 1]
      ]

      kings.each do |i|
        if i[0] >= 0 && i[1] >= 0 &&
          test_board[i[0]] && test_board[i[0]][i[1]] &&
          test_board[i[0]][i[1]].piece == "king" &&
          test_board[i[0]][i[1]].color != king_color
          threat = true
          throw :king_safety
        end
      end      

      knights = [
        [rank - 2, file + 1], [rank - 1, file + 2], [rank + 1, file + 2], [rank + 2, file + 1],
        [rank + 2, file - 1], [rank + 1, file - 2], [rank - 1, file - 2], [rank - 2, file - 1]
      ]

      knights.each do |i|
        if i[0] >= 0 && i[1] >= 0 &&
          test_board[i[0]] && test_board[i[0]][i[1]] &&
          test_board[i[0]][i[1]].piece == "knight" &&
          test_board[i[0]][i[1]].color != king_color
          threat = true
          throw :king_safety
        end
      end
    end
    return threat
  end

  def naive_pawn_moves(rank, file, board)
    output = []
    piece = board[rank][file]
    v_direction = piece > 0 ? -1 : 1
    if !board[rank + 1 * v_direction].nil? &&
      board[rank + 1 * v_direction][file].zero? &&
      output << pawn_move_builder([rank, file], [rank + 1 * v_direction, file], piece, false)
      if !board[rank + 2 * v_direction].nil? &&
        board[rank + 2 * v_direction][file].zero? &&
        ((rank == 1 && piece.color == "black") || (rank == 6 && piece.color == "white"))
        output << pawn_move_builder([rank, file], [rank + 2 * v_direction, file], piece, false)
      end
    end
    if !board[rank + 1 * v_direction].nil? &&
      !board[rank + 1 * v_direction][file - 1].nil? &&
      !(board[rank + 1 * v_direction][file - 1]).zero? &&
      piece.color != board[rank + 1 * v_direction][file - 1].color
      output << pawn_move_builder([rank, file], [rank + 1 * v_direction, file - 1], piece, false)
    end
    if !board[rank + 1 * v_direction].nil? &&
      !board[rank + 1 * v_direction][file + 1].nil? &&
      !(board[rank + 1 * v_direction][file + 1]).zero? &&
      piece.color != board[rank + 1 * v_direction][file + 1].color
      output << pawn_move_builder([rank, file], [rank + 1 * v_direction, file + 1], piece, false)
    end
    remove_out_of_bounds(output.flatten)
  end

  def pawn_move_builder(start_square, end_square, piece, capture)
    output = []
    if piece.color == "white" && end_square[0] == 0
      [2, 3, 4, 5].each { |i| output << Move.new(start_square, end_square, promotion: i, capture: capture) } 
    elsif piece.color == "black" && end_square[0] == 7
      [2, 3, 4, 5].each { |i| output << Move.new(start_square, end_square, promotion: i, capture: capture) }
    else 
      output << Move.new(start_square, end_square, capture: capture)
    end
    return output
  end

  def naive_king_moves(rank, file, board)
    output = []
    piece = board[rank][file]
    [-1, 0, 1].each do |rank_inc|
      [-1, 0, 1].each do |file_inc|
        if !(rank_inc.zero? && file_inc.zero?) &&
          !board[rank + rank_inc].nil? && !board[rank + rank_inc][file + file_inc].nil?
          if board[rank + rank_inc][file + file_inc].zero?
            output << Move.new([rank, file], [rank + rank_inc, file + file_inc], capture: false)
          elsif !(piece.color == board[rank + rank_inc][file + file_inc].color)
            output << Move.new([rank, file], [rank + rank_inc, file + file_inc], capture: true)
          end
        end
      end
    end
    if piece.color == "white"
      if castling[0].to_i == 1 && board[7][5].zero? && board[7][6].zero?
        output << Move.new([rank, file], [7, 6], capture: false)
      end
      if castling[1].to_i == 1 && board[7][3].zero? && board[7][2].zero? && board[7][1].zero?
        output << Move.new([rank, file], [7, 2], capture: false)
      end
    else
      if castling[2].to_i == 1 && board[0][5].zero? && board[0][6].zero?
        output << Move.new([rank, file], [0, 6], capture: false)
      end
      if castling[3].to_i == 1 && board[0][3].zero? && board[0][2].zero? && board[0][1].zero?
        output << Move.new([rank, file], [0, 2], capture: false)
      end
    end
    remove_out_of_bounds(output)
  end

  def naive_knight_moves(rank, file, board)
    output = []
    piece = board[rank][file]
    [[-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1]].each do |i|
      if !board[rank + i[0]].nil? &&
        !board[rank + i[0]][file + i[1]].nil?
        if board[rank + i[0]][file + i[1]].zero?
          output << Move.new([rank, file], [rank + i[0], file + i[1]], capture: false)
        elsif piece.color != board[rank + i[0]][file + i[1]].color
          output << Move.new([rank, file], [rank + i[0], file + i[1]], capture: true)
        end
      end
    end
    remove_out_of_bounds(output)
  end

  def naive_rook_moves(rank, file, board)
    output = []
    variables = [[-1, 0, rank], [1, 0, 7 - rank], [0, -1, file], [0, 1, 7 - file]]
    variables.each { |i| move_along(i[0], i[1], i[2], rank, file, output, board) }
    return output
  end

  def naive_bishop_moves(rank, file, board)
    output = []
    variables = [
      [-1, 1, [rank, 7 - file].min],
      [-1, -1, [rank, file].min],
      [1, -1, [7 - rank, file].min],
      [1, 1, [7 - rank, 7 - file].min]
    ]
    variables.each { |i| move_along(i[0], i[1], i[2], rank, file, output, board) }
    return output
  end

  def naive_queen_moves(rank, file, board)
    output = []
    output << naive_rook_moves(rank, file, board)
    output << naive_bishop_moves(rank, file, board)
    return output.flatten
  end


  def move_along(rank_mod, file_mod, sequence_builder, rank, file, output, board)
    piece = board[rank][file]
    (1..sequence_builder).each do |increment|
      if board[rank + increment * rank_mod][file + increment * file_mod].zero?
        output << Move.new([rank, file], [rank + increment * rank_mod, file + increment * file_mod], capture: false)
      elsif board[rank + increment * rank_mod][file + increment * file_mod].color != piece.color
        output << Move.new([rank, file], [rank + increment * rank_mod, file + increment * file_mod], capture: true)
        break
      else
        break
      end
    end
  end

  def king_safety_scan?(rank_mod, file_mod, sequence_builder, rank, file, board, threat_piece)
    king = board[rank][file]
    result = true
    (1..sequence_builder).each do |increment|
      square = board[rank + increment * rank_mod][file + increment * file_mod]
      if square.color != king.color && (square.piece == "queen" || square.piece == threat_piece)
        result = false
        break
      elsif square != 0
        break
      end
    end
    return result
  end

  def remove_out_of_bounds(output)
    output.select { |i| i.in_bounds }
  end
end
