module ParseBoard

	# mix in to String

	def to_board
		output = []
		self.split(",").each_with_index do |piece, i|
			output << [] if i % 8 == 0 
			output[-1] << piece.to_i     
		end
		return output
	end
end