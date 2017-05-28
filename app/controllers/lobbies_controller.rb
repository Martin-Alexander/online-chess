class LobbiesController < ApplicationController
	
	def index
		@games = Game.all.select { |game| !game.full? && game.white != current_user && game.black != current_user && game.black && game.white}
	end

	def show
	end

	def new
	end

	def create
	end

end