Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home", as: "home"
    # home: View home page

  resources :lobbies, only: [:index, :show, :new, :create] 
    # index: List of lobbies that you can join
    # show: Inside lobby
    # new: Choose between joining and creating a lobby
    # create: Making a new lobby 

  resources :games, only: [:show, :new, :create, :update] do
    # show: See the current state of a game (and play if possible)
    # new: Choose which engine you want to play against and which color you want to be
    # create: Make a new game
    # update: change the game status (in progress, white win, black win, or tie)
    resources :boards, only: [:index, :show, :update]
      # index: View all moves made during a gmae
      # show: Returns json of board state
      # update: Make a move
  end
  
  mount ActionCable.server, at: '/cable'

  require "sidekiq/web"
  mount Sidekiq::Web => '/sidekiq'

end
