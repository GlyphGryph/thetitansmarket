class CreateCharacterConditions < ActiveRecord::Migration
  def change
    create_table :character_conditions do |t|
      t.integer :character_id
      t.string :condition_id

      t.timestamps
    end
  end
end
