Rails.application.routes.draw do
  devise_for :users

  # TODO: Replace manual routing with "resources" rails helper 

  root to: "page#home", as: "home"

  resources :lobby, only: [:index, :new, :create] 
    # index: List of lobbies that you can join
    # create: Making a new lobby from 

  resources :games, only: [:show, :new, :create, :update]

  resources :games do
    resources :board, only: [:index, :show, :update]
  end
  
  mount ActionCable.server, at: '/cable'

  require "sidekiq/web"
  mount Sidekiq::Web => '/sidekiq'

end
