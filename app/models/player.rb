class Player < ApplicationRecord
  belongs_to :user
  has_many :games_as_white, class_name: "Game", foreign_key: "white_id"
  has_many :games_as_black, class_name: "Game", foreign_key: "black_id"
end
