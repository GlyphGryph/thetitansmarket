class DropTradeAskedCharacterPossessions < ActiveRecord::Migration
  def change
    drop_table :trade_asked_character_possessions
  end
end
