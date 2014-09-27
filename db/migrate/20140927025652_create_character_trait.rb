class CreateCharacterTrait < ActiveRecord::Migration
  def change
    create_table :character_traits do |t|
      t.integer :character_id
      t.string :trait_id
    end
  end
end
