class AddNameToLobby < ActiveRecord::Migration[5.1]
  def change
    add_column :lobbies, :name, :text
  end
end
