class CreateTradeOfferedCharacterPossessions < ActiveRecord::Migration
  def change
    create_table :trade_offered_character_possessions do |t|
      t.integer :trade_id
      t.integer :character_possession_id

      t.timestamps
    end
  end
end
