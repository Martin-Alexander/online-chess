module ChessPiece

	# mix in to Integer

	def piece
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
