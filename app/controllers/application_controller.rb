class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  Fixnum.send(:include, ChessPiece)
  Array.send(:include, SerializeBoard)
  String.send(:include, ParseBoard)
  
end
