class CreateLobbies < ActiveRecord::Migration[5.1]
  def change
    create_table :lobbies do |t|
      t.references :host
      t.references :nonhost
      t.timestamps
    end
  end
end
