class BoardController < ApplicationController

	def index
		#TODO: Viewing all moves for a game
	end

	def show
		board = Board.find(params[:id])
		render json: {
			board_data: board.board_data,
			white_to_move: board.white_to_move,
		}
	end

	def update
		move = moveify(params[:move])
		game = Game.find(params[:game_id])
		board = Board.find(params[:id])

		new_board = board.move(move)

		if (board.turn_player == current_user || board.turn_player.nil?) && new_board
			new_board.update(game: game)
			game_broadcast(new_board, game)
			engine_move(new_board, game) unless new_board.turn_player.human
		end
	end

	private

	def moveify(string)
		Move.new(
			[string[0].to_i, string[1].to_i], 
			[string[2].to_i, string[3].to_i], 
			promotion: string[4] ? string[4].to_i : 0
		)
	end

	def game_broadcast(board, game)
		ActionCable.server.broadcast "game_channel", {
			board_data: board.board_data,
			white_to_move: board.white_to_move,
			game_id: game.id.to_s
		}
	end

	def engine_move(board, game)
		EngineThought.perform_later(
			board.id,
			game.id,
			board.turn_player.email
		)
	end
end
