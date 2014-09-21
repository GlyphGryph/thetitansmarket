class DropTradeOfferedCharacterPossessions < ActiveRecord::Migration
  def change
    drop_table :trade_offered_character_possessions
  end
end
