Rails.application.routes.draw do
  devise_for :users

  root to: "game#board", as: "board"

  post "game", to: "game#game", as: "game"

  post "move", to: "game#move", as: "move"

  get "new", to: "game#new", as: "new"

end
