class Move

  attr_reader :start_square, :end_square, :promotion, :in_bounds, :is_capture
  
  def initialize(start_square, end_square, params ={})
    @start_square = start_square
    @end_square = end_square
    @in_bounds = in_bounds?
    @is_capture = is_capture
    @promotion = params[:promotion] || 0
  end

  def to_s
    move = "#{(@start_square[1] + 97).chr}" +
      "#{8 - @start_square[0] }" +
      " #{(@end_square[1] + 97).chr}" +
      "#{8 - @end_square[0]}"
    if !@promotion.zero?
      move = move + " promote to #{@promotion.piece}"
    end
    return move
  end

  private

  def valid_move_square(move_square)
    move_square.length == 2 && move_square.all? { |i| i.is_a? Integer }
  end

  def in_bounds?
    @start_square[0] <= 7 &&
      @start_square[0] >= 0 &&
      @start_square[1] <= 7 &&
      @start_square[1] >= 0 &&
      @end_square[0] <= 7 &&
      @end_square[0] >= 0 &&
      @end_square[1] <= 7 &&
      @end_square[1] >= 0
  end
end
