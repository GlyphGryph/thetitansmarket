class DropKnownAndAddProgressToCharacterKnowledge < ActiveRecord::Migration
  def change
    remove_column :character_knowledges, :known, :boolean
    add_column :character_knowledges, :progress, :integer
  end
end
