Rails.application.routes.draw do
  devise_for :users

  root to: "game#home", as: "home"

  get "single-player", to: "game#new_single_player", as: "new_single_player"
  get "single-player/create", to: "game#create_single_player", as: "create_single_player"

  get "multiplayer", to: "game#new_multiplayer", as: "new_multiplayer"
  get "multiplayer/create", to: "game#create_multiplayer", as: "create_multiplayer"

  get "multiplayer/join", to: "game#join", as: "join"

  post "create", to: "game#create", as: "create"

  get "game/:game_id", to: "game#show", as: "show"
  get "data/:game_id", to: "game#data", as: "data"
  
  post "move", to: "game#move", as: "move"
  
  mount ActionCable.server, at: '/cable'

  require "sidekiq/web"
  mount Sidekiq::Web => '/sidekiq'

end
