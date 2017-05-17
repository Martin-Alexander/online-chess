# Load the Rails application.
require_relative 'application'
require_relative '../app/helpers/chess_piece.rb'
require_relative '../app/helpers/parse_board.rb'
require_relative '../app/helpers/serialize_board.rb'


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

Rails.application.initialize!
