class CreateCharacterPossessions < ActiveRecord::Migration
  def change
    create_table :character_possessions do |t|
      t.integer :character_id
      t.string :possession_id

      t.timestamps
    end
  end
end
