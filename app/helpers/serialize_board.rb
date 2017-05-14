module SerializeBoard

	# mix in to Array

	def serialize_board
		self.flatten.join(",")
	end
end