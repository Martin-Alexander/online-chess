class ApplicationJob < ActiveJob::Base
  Fixnum.send(:include, ChessPiece)
  Array.send(:include, SerializeBoard)
  String.send(:include, ParseBoard)
end
