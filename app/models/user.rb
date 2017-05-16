class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    	:rememberable, :trackable
  has_many :games
  has_many :games_as_white, class_name: "Game", foreign_key: "white_id"
  has_many :games_as_black, class_name: "Game", foreign_key: "black_id"
end
