class GamesController < ApplicationController

  def new
  end

  def create
    if params[:ai]
      if params[:color] == "choose-white"
        new_game = Game.create(
          white: current_user ? current_user : User.find_by(email: "guest"),
          black: User.find_by(email: params[:ai])
        )
      else
        new_game = Game.create(
          white: User.find_by(email: params[:ai]),
          black: current_user ? current_user : User.find_by(email: "guest")
        )
      end
    else
      host = User.find(params[:lobby_host])
      nonhost = User.find(params[:nonhost])
      if params[:host_is] == "random"
        if rand > 0.5
          new_game = Game.create(white: host, black: nonhost)
        else
          new_game = Game.create(white: nonhost, black: host)
        end
      elsif params[:host_is] == "white"
        new_game = Game.create(white: host, black: nonhost)
      else
        new_game = Game.create(white: nonhost, black: host)
      end
    end
    Board.create(
      game: new_game,
      ply: 1,
      board_data: "-4,-2,-3,-5,-6,-3,-2,-4,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,4,2,3,5,6,3,2,4",
      white_to_move: true,
      castling: "1111",
      en_passant: "1111"
    )
    redirect_to game_path(new_game)
  end

  def show
    @game = Game.find(params[:id])
    @board = @game.boards.last
    if @board.turn_player && !@board.turn_player.human && @board.ply == 1
      EngineThought.perform_later(@board.id, @game.id, @board.turn_player.email)
    end
  end
end
