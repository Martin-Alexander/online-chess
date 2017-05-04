class AddHumanToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :human, :boolean
  end
end
