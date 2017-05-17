class EngineThought < ApplicationJob

	queue_as :default

	def perform(board_id, game_id)
		current_game = Game.find(game_id)
		new_board = Board.find(board_id)
	  computer_move_board = new_board.move(new_board.moves.sample)
    computer_move_board.game = current_game
    computer_move_board.save!
    ActionCable.server.broadcast "game_channel", { board_data: computer_move_board.board_data, white_to_move: computer_move_board.white_to_move, game_id: current_game.id.to_s }
  end
end