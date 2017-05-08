Rails.application.routes.draw do
  devise_for :users

  root to: "game#board"
  get "game_data", to: "game#game_data"
  post "move", to: "game#move", as: "move"

  mount ActionCable.server, at: '/cable'

end
