class LobbiesController < ApplicationController
	
	def index
		@lobbies = Lobby.all.select { |lobby| lobby.host != current_user }
	end

	def show
		@lobby = Lobby.find(params[:id]) rescue nil
		@player_color = @lobby.player_color
	end

	def new
	end

	def create
		lobby = Lobby.create(host: current_user, player_color: 0)
		lobby.update(name: "lobby ##{lobby.id}")
		redirect_to lobby_path(lobby)
	end

	def update

		lobby = Lobby.find(params[:id])
		lobby.update(name: params[:name]) if params[:name]
		player_color = if params[:player_color] == "Random"
			0
		elsif params[:player_color] == "Black"
			1
		else
			2
		end
			
		lobby.update(player_color: player_color) if params[:player_color]
		redirect_to lobby_path(lobby)
	end

	def destroy
		Lobby.find(params[:id]).destroy
		redirect_to home_path
	end
end