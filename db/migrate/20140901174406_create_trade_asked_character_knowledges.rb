class CreateTradeAskedCharacterKnowledges < ActiveRecord::Migration
  def change
    create_table :trade_asked_character_knowledges do |t|
      t.integer :trade_id
      t.integer :character_knowledge_id
      t.integer :duration
    end
  end
end
