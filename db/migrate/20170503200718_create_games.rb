class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.references :black
      t.references :white
      t.timestamps
    end
  end
end
