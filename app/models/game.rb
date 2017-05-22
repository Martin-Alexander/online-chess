class Game < ApplicationRecord
  belongs_to :black, class_name: "User"
  belongs_to :white, class_name: "User"
  has_many :boards, dependent: :destroy
end
