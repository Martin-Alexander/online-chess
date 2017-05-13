module ParseBoard

	# mix in to String

	def to_board
		output = []
		self.split(",").each_with_index do |piece, i|
      i % 8 == 0 ? output << [] : output[-1] << piece.to_i     
    end
    return output
	end
end