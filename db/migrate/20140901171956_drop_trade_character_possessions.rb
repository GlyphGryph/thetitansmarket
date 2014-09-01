class DropTradeCharacterPossessions < ActiveRecord::Migration
  def change
    drop_table :trade_character_possessions
  end
end
