class CreateCharacterKnowledges < ActiveRecord::Migration
  def change
    create_table :character_knowledges do |t|
      t.integer :character_id
      t.string :knowledge_id
      t.boolean :known

      t.timestamps
    end
  end
end
