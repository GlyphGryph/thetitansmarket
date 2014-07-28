class CreateCharacterActions < ActiveRecord::Migration
  def change
    create_table :character_actions do |t|
      t.integer :character_id
      t.integer :action_id

      t.timestamps
    end
  end
end
