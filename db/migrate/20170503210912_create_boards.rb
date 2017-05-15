class CreateBoards < ActiveRecord::Migration[5.1]
  def change
    create_table :boards do |t|
      t.references :game, foreign_key: true
      t.integer :ply, default: 1
      t.boolean :white_to_move, default: true
      t.string :board_data, default: "-4,-2,-3,-5,-6,-3,-2,-4,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,4,2,3,5,6,3,2,4"
      t.string :castling, default: "1111"
      t.string :en_passant, default: "1111"
      t.timestamps
    end
  end
end
