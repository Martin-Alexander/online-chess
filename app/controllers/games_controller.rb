class GamesController < ApplicationController

  def new
    # Rendering new single player game screen wherein you choose which AI to play against
  end

  def create
    create_game = lambda { |white, black| Game.create(white: white, black: black) }

    if params[:ai] # Single player game
      new_game = if params[:color] == "choose-white"
        create_game.call(current_user, User.find_by(email: params[:ai]))
      else
        create_game.call(User.find_by(email: params[:ai]), current_user)
      end
    else # Multiplayer game
      host = User.find(params[:lobby_host])
      nonhost = User.find(params[:nonhost])
      new_game = if params[:host_is] == "random"
        rand > 0.5 ? create_game.call(host, nonhost) : create_game.call(nonhost, host)
      elsif params[:host_is] == "white"
        create_game.call(host, nonhost)
      else
        create_game.call(nonhost, host)
      end
    end

    Board.create(game: new_game)
    redirect_to game_path(new_game)
  end

  def show
    @game = Game.find(params[:id])
    @board = @game.boards.last

    if @board.turn_player && !@board.turn_player.human && @board.ply == 1 
      # Automatically run EngineThought if it's the first ply and the turnplayer is a computer
      EngineThought.perform_later(@board.id, @game.id, @board.turn_player.email)
    end
  end
end
