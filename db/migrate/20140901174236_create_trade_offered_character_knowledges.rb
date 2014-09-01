class CreateTradeOfferedCharacterKnowledges < ActiveRecord::Migration
  def change
    create_table :trade_offered_character_knowledges do |t|
      t.integer :trade_id
      t.integer :character_knowledge_id
      t.integer :duration
    end
  end
end
