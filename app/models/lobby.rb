class Lobby < ApplicationRecord
	belongs_to :host, class_name: "User"
  belongs_to :nonhost, class_name: "User", optional: true

  def full?
  	self.nonhost ? true : false
  end
end
