class CreateCharacters < ActiveRecord::Migration
  def change
    create_table :characters do |t|
      t.string :name
      t.integer :hp
      t.integer :mhp
      t.integer :happy
      t.integer :mhappy
      t.integer :world_id
      t.integer :user_id

      t.timestamps
    end
  end
end
