# Load the Rails application.
require_relative 'application'

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
