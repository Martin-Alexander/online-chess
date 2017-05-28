class AddPlayerColorToLobby < ActiveRecord::Migration[5.1]
  def change
    add_column :lobbies, :player_color, :integer
  end
end
