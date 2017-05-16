Rails.application.routes.draw do
  devise_for :users

  root to: "game#home", as: "home"

  get "new", to: "game#new", as: "new"
  post "create", to: "game#create", as: "create"

  get "game/:game_id", to: "game#show", as: "show"
  get "data/:game_id", to: "game#data", as: "data"
  
  post "move", to: "game#move", as: "move"
  
  mount ActionCable.server, at: '/cable'

  require "sidekiq/web"
  mount Sidekiq::Web => '/sidekiq'

end
