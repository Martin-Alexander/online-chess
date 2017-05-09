Rails.application.routes.draw do
  devise_for :users

  root to: "game#board", as: "board"
  get "data", to: "game#data", as: "data"
  post "move", to: "game#move", as: "move"
  get "reset", to: "game#reset", as: "reset"

  mount ActionCable.server, at: '/cable'

end
