class AddKnowledgeIdToTradeKnowledges < ActiveRecord::Migration
  def change
    add_column :trade_asked_character_knowledges, :knowledge_id, :string
    add_column :trade_offered_character_knowledges, :knowledge_id, :string
    remove_column :trade_offered_character_knowledges, :character_knowledge_id, :integer
    remove_column :trade_asked_character_knowledges, :character_knowledge_id, :integer
  end
end
