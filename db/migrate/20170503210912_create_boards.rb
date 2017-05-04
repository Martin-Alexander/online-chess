class CreateBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :boards do |t|
      t.references :game, foreign_key: true
      t.integer :ply
      t.string :board_data
      t.boolean :white_to_move
      t.string :castling
      t.string :en_passant
      t.timestamps
    end
  end
end
