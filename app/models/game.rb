class Game < ApplicationRecord
  belongs_to :black, class_name: "Player"
  belongs_to :white, class_name: "Player"
  has_many :boards
end
