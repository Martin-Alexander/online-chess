class Board < ApplicationRecord
  belongs_to :game

  module ChessPieces
    def piece
      if !(self.is_a? Integer)
        raise ArgumentError.new "arguement must be of type Integer"
      elsif !((-6..-1).to_a + (0..6).to_a).include? self
        raise ArgumentError.new "integer #{self} is out of range"
      end

      case self.abs
        when 6 then "king"
        when 5 then "queen"
        when 4 then "rook"
        when 3 then "bishop"
        when 2 then "knight"
        when 1 then "pawn"
        when 0 then nil
      end
    end

    def color
      if self < 0
        "black"
      elsif self > 0
        "white"
      else
        nil
      end
    end
  end

  Fixnum.send(:include, ChessPieces)

  def move(move)
    setup
    legal = moves.any? do |legal_move|
      legal_move.start_square == move.start_square &&
      legal_move.end_square == move.end_square
    end
    if legal
      new_board = execute_move(@board, move)
      return new_board
    else
      return false
    end
  end

  def moves
    setup
    output = []
    each_square do |rank, file|
      if right_color?(rank, file) && !naive_moves(rank, file, @board).nil?
        naive_moves(rank, file, @board).each do |naive_move|
          if king_safe?(naive_move)
            output << naive_move
          end
        end
      end
    end
    return output
  end


  private

  def execute_move(board, move)
    board_copy = board.map { |i| i.dup }
    board_copy[move.end_square[0]][move.end_square[1]] = board_copy[move.start_square[0]][move.start_square[1]]
    board_copy[move.start_square[0]][move.start_square[1]] = 0
    output_board = ""
    board_copy = board_copy.flatten
    board_copy.each { |i| output_board << "#{i.to_s}," }
    output_board[-1] = ""
    Board.new(game_id: game_id, ply: @ply + 1, board_data: output_board, white_to_move: !@white_to_move, castling: "0000", en_passant: "0000")
  end

  def setup
    @ply = ply

    @board = []
    board_data.split(",").each_with_index do |piece, i|
      @board << [] if i % 8 == 0
      @board[-1] << piece.to_i
    end

    @white_to_move = white_to_move

    @castling = {}
    @castling[:white_king] = castling[0] == 1
    @castling[:white_queen] = castling[1] == 1
    @castling[:black_king] = castling[2] == 1
    @castling[:black_queen] = castling[3] == 1

    @en_passant = []
    @en_passant << [en_passant[0].to_i, en_passant[1].to_i]
    @en_passant << [en_passant[2].to_i, en_passant[3].to_i]
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

  def find_king(board)
    right_color = @white_to_move ? "white" : "black"
    output = nil
    each_square do |rank, file|
      if !board[rank][file].zero? &&
        board[rank][file].piece == "king" &&
        board[rank][file].color == right_color
        output = [rank, file]
        break
      end
    end
    raise Error.new "missing king on board" if output.nil?
    return output
  end

  def right_color?(rank, file)
    right_color = @white_to_move ? "white" : "black"
    @board[rank][file].color == right_color
  end

  def king_safe?(move)
    right_color = @white_to_move ? "black" : "white"
    test_board = @board.map { |i| i.dup }
    test_board[move.end_square[0]][move.end_square[1]] = test_board[move.start_square[0]][move.start_square[1]]
    test_board[move.start_square[0]][move.start_square[1]] = 0
    king_location = find_king(test_board)
    safety = true
    catch :king_safety do
      if local_threats_to_king?(test_board, king_location[0], king_location[1])
        safety = false
        throw :king_safety
      end
      each_square do |rank, file|
        if ["rook", "bishop", "queen"].include?(test_board[rank][file].piece) &&
          test_board[rank][file].color == right_color
          naive_moves(rank, file, test_board).each do |enemy_move|
            if enemy_move.end_square == king_location
              safety = false
              throw :king_safety
            end
          end
        end
      end
    end
    return safety
  end

  def local_threats_to_king?(board, rank, file)
    threat = false
    catch :king_safety do
      if @white_to_move
        king_color = "white"
        pawns = [[rank - 1, file - 1], [rank - 1, file + 1]]
      else
        king_color = "black"
        pawns = [[rank + 1, file - 1], [rank + 1, file + 1]]
      end

      pawns.each do |i|
        if board[i[0]] && board[i[0]][i[1]] &&
          board[i[0]][i[1]].piece == "pawn" &&
          board[i[0]][i[1]].color != king_color
          threat = true
          throw :king_safety
        end
      end

      knights = [
        [rank - 2, file + 1], [rank - 1, file + 2], [rank + 1, file + 2], [rank + 2, file + 1],
        [rank + 2, file - 1], [rank + 1, file - 2], [rank - 1, file - 2], [rank - 2, file - 1]
      ]

      knights.each do |i|
        if i[0] > 0 && i[1] > 0 &&
          board[i[0]] && board[i[0]][i[1]] &&
          board[i[0]][i[1]].piece == "knight" &&
          board[i[0]][i[1]].color != king_color
          threat = true
          throw :king_safety
        end
      end
    end
    return threat
  end

  def valid_pieces(pieces_array)
    pieces_array.length == 8 && pieces_array.all? { |i| i.length == 8 }
  end

  def valid_castling_hash(castling_hash)
    castling_hash.length == 4 &&
    !!castling_hash[:white_king] == castling_hash[:white_king] &&
    !!castling_hash[:white_queen] == castling_hash[:white_queen] &&
    !!castling_hash[:black_king] == castling_hash[:black_king] &&
    !!castling_hash[:black_queen] == castling_hash[:black_queen]
  end

  def valid_en_passant(en_passant_array)
    en_passant_array.length == 2 && en_passant_array.all? { |i| i.length == 2}
    # TODO: Make more robust en passant validation using game logic
  end

  def standard_board_setup
    [
      [-4, -2, -3, -5, -6, -3, -2, -4],
      [-1, -1, -1, -1, -1, -1, -1, -1],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0, 0],
      [1, 1, 1, 1, 1, 1, 1, 1],
      [4, 2, 3, 5, 6, 3, 2, 4]
    ]
  end

  def naive_pawn_moves(rank, file, board)
    output = []
    piece = board[rank][file]
    v_direction = piece > 0 ? -1 : 1
    if !board[rank + 1 * v_direction].nil? &&
      board[rank + 1 * v_direction][file].zero? &&
      output << Move.new([rank, file], [rank + 1 * v_direction, file])
      if !board[rank + 2 * v_direction].nil?
        board[rank + 2 * v_direction][file].zero? &&
        ((rank == 1 && piece.color == "black") || (rank == 6 && piece.color == "white"))
        output << Move.new([rank, file], [rank + 2 * v_direction, file])
      end
    end
    if !board[rank + 1 * v_direction].nil? &&
      !board[rank + 1 * v_direction][file - 1].nil? &&
      !(board[rank + 1 * v_direction][file - 1]).zero? &&
      piece.color != board[rank + 1 * v_direction][file - 1].color
      output << Move.new([rank, file], [rank + 1 * v_direction, file - 1])
    end
    if !board[rank + 1 * v_direction].nil? &&
      !board[rank + 1 * v_direction][file + 1].nil? &&
      !(board[rank + 1 * v_direction][file + 1]).zero? &&
      piece.color != board[rank + 1 * v_direction][file + 1].color
      output << Move.new([rank, file], [rank + 1 * v_direction, file + 1])
    end
    remove_out_of_bounds(output)
  end

  def naive_king_moves(rank, file, board)
    output = []
    piece = board[rank][file]
    [-1, 0, 1].each do |rank_inc|
      [-1, 0, 1].each do |file_inc|
        if !(rank_inc.zero? && file_inc.zero?) &&
          !board[rank + rank_inc].nil? && !board[rank + rank_inc][file + file_inc].nil? &&
          !(piece.color == board[rank + rank_inc][file + file_inc].color)
          output << Move.new([rank, file], [rank + rank_inc, file + file_inc])
        end
      end
    end
    remove_out_of_bounds(output)
  end

  def naive_knight_moves(rank, file, board)
    output = []
    piece = board[rank][file]
    [[-2, 1], [-1, 2], [1, 2], [2, 1], [2, -1], [1, -2], [-1, -2], [-2, -1]].each do |i|
      if !board[rank + i[0]].nil? &&
        !board[rank + i[0]][file + i[1]].nil? &&
        (board[rank + i[0]][file + i[1]].zero? ||
        piece.color != board[rank + i[0]][file + i[1]].color)
        output << Move.new([rank, file], [rank + i[0], file + i[1]])
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

  def move_along (rank_mod, file_mod, sequence_builder, rank, file, output, board)
    piece = board[rank][file]
    (1..sequence_builder).each do |increment|
      move = Move.new([rank, file], [rank + increment * rank_mod, file + increment * file_mod])
      if board[rank + increment * rank_mod][file + increment * file_mod].zero?
        output << move
      elsif board[rank + increment * rank_mod][file + increment * file_mod].color != piece.color
        output << move
        break
      else
        break
      end
    end
  end

  def each_square
    (0..7).each do |rank|
      (0..7).each do |file|
        yield(rank, file)
      end
    end
  end

  def remove_out_of_bounds(output)
    output.select { |i| i.in_bounds }
  end

  def board_visualization(chess_board)
    if !chess_board.is_a? ChessBoard
      raise ArgumentError.new "board_visualization must be passed arguement of type ChessBoard"
    end
    chess_board.board.each_with_index do |row, i|
      row.each { |square| print square < 0 ? "#{square} " : " #{square} " }
      puts
    end
  end
end
