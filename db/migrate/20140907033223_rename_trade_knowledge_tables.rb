class RenameTradeKnowledgeTables < ActiveRecord::Migration
  def change
    rename_table :trade_asked_character_knowledges, :trade_asked_knowledges
    rename_table :trade_offered_character_knowledges, :trade_offered_knowledges
  end
end
